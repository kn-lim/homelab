// Validates a repository's ci.yaml parses and that each Terraform stack is a clean path.
//
// Usage: ci-validate [repository directory]
package main

import (
	"errors"
	"fmt"
	"os"
	"path"
	"path/filepath"

	"github.com/kn-lim/homelab/apps/webhook/pkg/ci"
)

const stackFile = "terragrunt.stack.hcl"

func main() {
	dir := "."
	if len(os.Args) > 1 {
		dir = os.Args[1]
	}
	if err := validate(dir); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func validate(dir string) error {
	data, err := os.ReadFile(filepath.Join(dir, ci.ConfigFile))
	if err != nil {
		return err
	}
	cfg, err := ci.ParseConfig(data)
	if err != nil {
		return err
	}
	var errs []error
	for _, e := range cfg.Terraform.Run {
		if clean := path.Clean(e.Stack); clean != e.Stack {
			errs = append(errs, fmt.Errorf("terraform stack %q is not a clean path, use %q", e.Stack, clean))
			continue
		}
		if !exists(dir, e.Stack, stackFile) && !exists(dir, e.Stack, "generated", stackFile) {
			errs = append(errs, fmt.Errorf("terraform stack %q has no %s", e.Stack, stackFile))
		}
	}
	return errors.Join(errs...)
}

func exists(parts ...string) bool {
	_, err := os.Stat(filepath.Join(parts...))
	return err == nil
}
