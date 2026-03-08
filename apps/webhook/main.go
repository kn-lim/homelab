package main

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"net/http"
	"os"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/google/go-github/v83/github"
	"go.uber.org/zap"
)

const delay int32 = 5 // seconds

var (
	client        *sqs.Client
	webhookSecret []byte
	sqsURL        string

	logger = zap.Must(zap.NewProduction()).Sugar()
)

type Message struct {
	Repo   string `json:"repo"`
	Ref    string `json:"ref"`
	Before string `json:"before"`
	After  string `json:"after"`
}

func init() {
	secret := os.Getenv("GITHUB_WEBHOOK_SECRET")
	if secret == "" {
		logger.Fatal("GITHUB_WEBHOOK_SECRET is not set")
	}
	webhookSecret = []byte(secret)

	sqsURL = os.Getenv("AWS_SQS_URL")
	if sqsURL == "" {
		logger.Fatal("AWS_SQS_URL is not set")
	}

	cfg, err := config.LoadDefaultConfig(context.Background())
	if err != nil {
		logger.Fatalw("failed to load AWS config",
			"error", err,
		)
	}
	client = sqs.NewFromConfig(cfg)
}

func handler(ctx context.Context, request events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
	defer logger.Sync()

	// Check if API Gateway request is base64 encoded
	bodyBytes := []byte(request.Body)
	if request.IsBase64Encoded {
		var decodeErr error
		bodyBytes, decodeErr = base64.StdEncoding.DecodeString(request.Body)
		if decodeErr != nil {
			logger.Errorw("failed to decode base64 body",
				"error", decodeErr,
			)
			return events.APIGatewayV2HTTPResponse{
				StatusCode: http.StatusBadRequest,
			}, nil
		}
	}

	// Convert API Gateway request to standard HTTP request
	httpRequest, err := http.NewRequest(request.RequestContext.HTTP.Method, request.RequestContext.HTTP.Path, bytes.NewReader(bodyBytes))
	if err != nil {
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusInternalServerError,
		}, nil
	}
	for k, v := range request.Headers {
		httpRequest.Header.Set(k, v)
	}

	// Validate the request
	payload, err := github.ValidatePayload(httpRequest, webhookSecret)
	if err != nil {
		logger.Errorw("signature validation failed",
			"error", err,
		)
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusForbidden,
		}, nil
	}

	logger.Infow("received request",
		"method", httpRequest.Method,
		"path", httpRequest.URL.Path,
	)

	// Handle Github webhook events
	event, err := github.ParseWebHook(github.WebHookType(httpRequest), payload)
	if err != nil {
		logger.Errorw("failed to parse webhook",
			"error", err,
		)
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusBadRequest,
		}, nil
	}

	logger.Infow("received event",
		"type", github.WebHookType(httpRequest),
	)

	var msg Message
	switch event := event.(type) {
	case *github.PingEvent:
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusOK,
		}, nil
	case *github.PushEvent:
		if event.GetDeleted() {
			return events.APIGatewayV2HTTPResponse{
				StatusCode: http.StatusOK,
			}, nil
		}

		msg = Message{
			Repo:   event.Repo.GetSSHURL(),
			Ref:    strings.TrimPrefix(event.GetRef(), "refs/heads/"),
			Before: event.GetBefore(),
			After:  event.GetAfter(),
		}
	default:
		logger.Infow("unsupported event type",
			"type", github.WebHookType(httpRequest),
		)
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusOK,
		}, nil
	}

	body, err := json.Marshal(msg)
	if err != nil {
		logger.Errorw("failed to marshal message",
			"error", err,
		)
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusInternalServerError,
		}, nil
	}

	// Send message to SQS
	result, err := client.SendMessage(ctx, &sqs.SendMessageInput{
		DelaySeconds: delay,
		MessageBody:  aws.String(string(body)),
		QueueUrl:     aws.String(sqsURL),
	})
	if err != nil {
		logger.Errorw("failed to send SQS message",
			"error", err,
		)
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusInternalServerError,
		}, nil
	}
	logger.Infow("sent SQS message",
		"messageId", aws.ToString(result.MessageId),
		"msg", msg,
	)

	return events.APIGatewayV2HTTPResponse{
		StatusCode: http.StatusOK,
	}, nil
}

func main() {
	lambda.Start(handler)
}
