package ci

import (
	"context"
	"fmt"
	"strings"

	"github.com/google/go-github/v93/github"
)

// GitHubSource reads repository content through the GitHub API.
type GitHubSource struct {
	Client *github.Client
}

func splitRepo(repo string) (string, string, error) {
	owner, name, ok := strings.Cut(repo, "/")
	if !ok {
		return "", "", fmt.Errorf("repository %q is not owner/name", repo)
	}
	return owner, name, nil
}

func (s GitHubSource) ReadFile(ctx context.Context, repo, ref, path string) ([]byte, error) {
	owner, name, err := splitRepo(repo)
	if err != nil {
		return nil, err
	}
	file, _, _, err := s.Client.Repositories.GetContents(ctx, owner, name, path, &github.RepositoryContentGetOptions{Ref: ref})
	if err != nil {
		return nil, err
	}
	if file == nil {
		return nil, fmt.Errorf("%s is not a file", path)
	}
	content, err := file.GetContent()
	if err != nil {
		return nil, err
	}
	return []byte(content), nil
}

func (s GitHubSource) HeadCommit(ctx context.Context, repo, branch string) (string, error) {
	owner, name, err := splitRepo(repo)
	if err != nil {
		return "", err
	}
	b, _, err := s.Client.Repositories.GetBranch(ctx, owner, name, branch, 1)
	if err != nil {
		return "", err
	}
	return b.GetCommit().GetSHA(), nil
}
