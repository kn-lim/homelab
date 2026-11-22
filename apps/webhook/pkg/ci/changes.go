package ci

import (
	"slices"

	"github.com/google/go-github/v93/github"
)

// ChangedPaths returns the sorted, unique paths that the commits of a push added, removed, or modified.
func ChangedPaths(commits []*github.HeadCommit) []string {
	var paths []string
	for _, c := range commits {
		paths = append(paths, c.Added...)
		paths = append(paths, c.Removed...)
		paths = append(paths, c.Modified...)
	}
	slices.Sort(paths)
	return slices.Compact(paths)
}
