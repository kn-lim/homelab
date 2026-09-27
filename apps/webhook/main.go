package main

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"log/slog"
	"net/http"
	"os"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/google/go-github/v92/github"
)

const delay int32 = 5 // seconds

var (
	client        *sqs.Client
	webhookSecret []byte
	sqsURL        string

	logger = slog.New(slog.NewJSONHandler(os.Stderr, nil))
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
		logger.Error("GITHUB_WEBHOOK_SECRET is not set")
		os.Exit(1)
	}
	webhookSecret = []byte(secret)

	sqsURL = os.Getenv("AWS_SQS_URL")
	if sqsURL == "" {
		logger.Error("AWS_SQS_URL is not set")
		os.Exit(1)
	}

	cfg, err := config.LoadDefaultConfig(context.Background())
	if err != nil {
		logger.Error("failed to load AWS config",
			"error", err,
		)
		os.Exit(1)
	}
	client = sqs.NewFromConfig(cfg)
}

func handler(ctx context.Context, request events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
	// Check if API Gateway request is base64 encoded
	bodyBytes := []byte(request.Body)
	if request.IsBase64Encoded {
		var decodeErr error
		bodyBytes, decodeErr = base64.StdEncoding.DecodeString(request.Body)
		if decodeErr != nil {
			logger.Error("failed to decode base64 body",
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
		logger.Error("signature validation failed",
			"error", err,
		)
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusForbidden,
		}, nil
	}

	logger.Info("received request",
		"method", httpRequest.Method,
		"path", httpRequest.URL.Path,
	)

	// Handle Github webhook events
	event, err := github.ParseWebHook(github.WebHookType(httpRequest), payload)
	if err != nil {
		logger.Error("failed to parse webhook",
			"error", err,
		)
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusBadRequest,
		}, nil
	}

	logger.Info("received event",
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

		ref := strings.TrimPrefix(event.GetRef(), "refs/heads/")
		// Check for non-target branches (main and develop)
		if ref != "main" && ref != "develop" {
			logger.Info("ignoring push to non-target branch",
				"ref", ref,
			)
			return events.APIGatewayV2HTTPResponse{
				StatusCode: http.StatusOK,
			}, nil
		}

		msg = Message{
			Repo:   event.Repo.GetFullName(),
			Ref:    ref,
			Before: event.GetBefore(),
			After:  event.GetAfter(),
		}
	default:
		logger.Info("unsupported event type",
			"type", github.WebHookType(httpRequest),
		)
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusOK,
		}, nil
	}

	body, err := json.Marshal(msg)
	if err != nil {
		logger.Error("failed to marshal message",
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
		logger.Error("failed to send SQS message",
			"error", err,
		)
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusInternalServerError,
		}, nil
	}
	logger.Info("sent SQS message",
		"messageId", aws.ToString(result.MessageId),
		"payload", msg,
	)

	return events.APIGatewayV2HTTPResponse{
		StatusCode: http.StatusOK,
	}, nil
}

func main() {
	lambda.Start(handler)
}
