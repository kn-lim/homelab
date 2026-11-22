package ci

import (
	"slices"
	"strings"
)

// Commands returns the commands for the pushed repository.
func Commands(cfg *Config, changed []string) []string {
	return commands(cfg, changed, true)
}

// DownstreamCommands returns the commands for a downstream repository.
func DownstreamCommands(cfg *Config, changed []string) []string {
	return commands(cfg, changed, false)
}

func commands(cfg *Config, changed []string, pushed bool) []string {
	var cmds []string

	for _, e := range cfg.Terraform.Run {
		if anyMatch(changed, e.WhenModified) || (pushed && anyMatch(changed, []string{e.Stack})) {
			cmds = append(cmds, TerraformApply+e.Stack)
		}
	}

	if pushed {
		for _, e := range cfg.Deploy.Run {
			if e.Lambda != nil && anyMatch(changed, []string{e.Application}) {
				cmds = append(cmds, DeployLambda+e.Application+" "+e.Lambda.FunctionName+" "+e.Lambda.S3Key)
			}
		}
	}

	slices.Sort(cmds)
	return slices.Compact(cmds)
}

func anyMatch(changed, prefixes []string) bool {
	for _, c := range changed {
		for _, p := range prefixes {
			if matches(c, p) {
				return true
			}
		}
	}
	return false
}

// matches reports whether path equals prefix or is inside it.
func matches(path, prefix string) bool {
	return path == prefix || strings.HasPrefix(path, prefix+"/")
}
