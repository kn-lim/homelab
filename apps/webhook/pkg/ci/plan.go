package ci

import (
	"context"
	"errors"
	"fmt"
)

// ConfigFile is the path of ci.yaml in each repository.
const ConfigFile = "ci.yaml"

// downstreamBranch is the branch that downstream repositories load code from.
const downstreamBranch = "main"

// Message is the SQS message body that Argo Events reads.
type Message struct {
	Repo     string   `json:"repo"`
	Ref      string   `json:"ref"`
	Before   string   `json:"before"`
	After    string   `json:"after"`
	Commands []string `json:"commands"`
}

// Push describes one push event. Repo is "owner/name", and Ref is the branch.
type Push struct {
	Repo    string
	Ref     string
	Before  string
	After   string
	Changed []string
}

// Source reads repository content.
type Source interface {
	ReadFile(ctx context.Context, repo, ref, path string) ([]byte, error)
	HeadCommit(ctx context.Context, repo, branch string) (string, error)
}

// Plan returns a message for each repository that has commands: the pushed repository and its downstream repositories.
func Plan(ctx context.Context, src Source, push Push) ([]Message, error) {
	cfg, err := load(ctx, src, push.Repo, push.After)
	if err != nil {
		return nil, err
	}

	var msgs []Message
	if cmds := Commands(cfg, push.Changed); len(cmds) > 0 {
		msgs = append(msgs, Message{Repo: push.Repo, Ref: push.Ref, Before: push.Before, After: push.After, Commands: cmds})
	}

	if push.Ref != downstreamBranch {
		return msgs, nil
	}

	var errs []error
	for _, repo := range cfg.Downstream {
		msg, err := planDownstream(ctx, src, repo, push.Changed)
		if err != nil {
			errs = append(errs, err)
			continue
		}
		if msg != nil {
			msgs = append(msgs, *msg)
		}
	}
	return msgs, errors.Join(errs...)
}

func planDownstream(ctx context.Context, src Source, repo string, changed []string) (*Message, error) {
	head, err := src.HeadCommit(ctx, repo, downstreamBranch)
	if err != nil {
		return nil, fmt.Errorf("head of %s@%s: %w", repo, downstreamBranch, err)
	}
	cfg, err := load(ctx, src, repo, head)
	if err != nil {
		return nil, err
	}
	cmds := DownstreamCommands(cfg, changed)
	if len(cmds) == 0 {
		return nil, nil
	}
	return &Message{Repo: repo, Ref: downstreamBranch, Before: head, After: head, Commands: cmds}, nil
}

// load reads and parses ci.yaml.
func load(ctx context.Context, src Source, repo, ref string) (*Config, error) {
	data, err := src.ReadFile(ctx, repo, ref, ConfigFile)
	if err != nil {
		return nil, fmt.Errorf("read %s from %s@%s: %w", ConfigFile, repo, ref, err)
	}
	cfg, err := ParseConfig(data)
	if err != nil {
		return nil, fmt.Errorf("%s@%s: %w", repo, ref, err)
	}
	return cfg, nil
}
