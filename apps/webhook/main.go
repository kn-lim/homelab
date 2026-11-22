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
	"github.com/google/go-github/v93/github"

	"github.com/kn-lim/homelab/apps/webhook/pkg/ci"
)

const delay int32 = 5 // seconds

var (
	client        *sqs.Client
	webhookSecret []byte
	sqsURL        string
	source        ci.Source
)

func init() {
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stderr, nil)))

	secret := os.Getenv("GITHUB_WEBHOOK_SECRET")
	if secret == "" {
		slog.Error("GITHUB_WEBHOOK_SECRET is not set")
		os.Exit(1)
	}
	webhookSecret = []byte(secret)

	sqsURL = os.Getenv("AWS_SQS_URL")
	if sqsURL == "" {
		slog.Error("AWS_SQS_URL is not set")
		os.Exit(1)
	}

	token := os.Getenv("GITHUB_TOKEN")
	if token == "" {
		slog.Error("GITHUB_TOKEN is not set")
		os.Exit(1)
	}
	gh, err := github.NewClient(github.WithAuthToken(token))
	if err != nil {
		slog.Error("failed to create GitHub client",
			"error", err,
		)
		os.Exit(1)
	}
	source = ci.GitHubSource{Client: gh}

	cfg, err := config.LoadDefaultConfig(context.Background())
	if err != nil {
		slog.Error("failed to load AWS config",
			"error", err,
		)
		os.Exit(1)
	}
	client = sqs.NewFromConfig(cfg)
}

func handler(ctx context.Context, request events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
	// Add the GitHub delivery ID to every log line of this request
	logger := slog.With("delivery", request.Headers["x-github-delivery"])

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

	var push ci.Push
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

		push = ci.Push{
			Repo:    event.Repo.GetFullName(),
			Ref:     ref,
			Before:  event.GetBefore(),
			After:   event.GetAfter(),
			Changed: ci.ChangedPaths(event.Commits),
		}
	default:
		logger.Info("unsupported event type",
			"type", github.WebHookType(httpRequest),
		)
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusOK,
		}, nil
	}

	msgs, planErr := ci.Plan(ctx, source, push)
	if planErr != nil {
		logger.Error("failed to plan CI commands",
			"error", planErr,
		)
	}
	if len(msgs) == 0 && planErr == nil {
		logger.Info("no commands for push",
			"repo", push.Repo,
			"ref", push.Ref,
		)
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusOK,
		}, nil
	}

	sendFailed := false
	for _, msg := range msgs {
		if err := send(ctx, logger, msg); err != nil {
			sendFailed = true
		}
	}
	if planErr != nil || sendFailed {
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusInternalServerError,
		}, nil
	}

	return events.APIGatewayV2HTTPResponse{
		StatusCode: http.StatusOK,
	}, nil
}

// send sends one message to SQS and logs the result.
func send(ctx context.Context, logger *slog.Logger, msg ci.Message) error {
	body, err := json.Marshal(msg)
	if err != nil {
		logger.Error("failed to marshal message",
			"error", err,
		)
		return err
	}

	result, err := client.SendMessage(ctx, &sqs.SendMessageInput{
		DelaySeconds: delay,
		MessageBody:  aws.String(string(body)),
		QueueUrl:     aws.String(sqsURL),
	})
	if err != nil {
		logger.Error("failed to send SQS message",
			"error", err,
		)
		return err
	}
	logger.Info("sent SQS message",
		"messageId", aws.ToString(result.MessageId),
		"payload", msg,
	)
	return nil
}

func main() {
	lambda.Start(handler)
}
