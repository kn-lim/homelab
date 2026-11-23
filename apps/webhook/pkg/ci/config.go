package ci

import (
	"bytes"
	"fmt"
	"strings"

	"go.yaml.in/yaml/v4"
)

// Config is a parsed ci.yaml file.
type Config struct {
	// Downstream lists the repositories that load code from this one.
	Downstream []string `yaml:"downstream"`
	// Groups only holds YAML anchors for whenModified.
	Groups yaml.Node `yaml:"groups"`

	Deploy struct {
		Run []DeployEntry `yaml:"run"`
	} `yaml:"deploy"`

	Terraform struct {
		Run []TerraformEntry `yaml:"run"`
	} `yaml:"terraform"`
}

type DeployEntry struct {
	Application string  `yaml:"application"`
	Lambda      *Lambda `yaml:"lambda"`
}

type Lambda struct {
	FunctionName string `yaml:"functionName"`
	S3Key        string `yaml:"s3Key"`
}

type TerraformEntry struct {
	// Stack is the stack folder that contains the terragrunt.stack.hcl.
	Stack        string `yaml:"stack"`
	WhenModified Paths  `yaml:"whenModified"`
}

// Paths is a list of file paths.
type Paths []string

func (p *Paths) UnmarshalYAML(value *yaml.Node) error {
	var walk func(n *yaml.Node) error
	walk = func(n *yaml.Node) error {
		switch n.Kind {
		case yaml.ScalarNode:
			*p = append(*p, strings.TrimSuffix(n.Value, "/"))
		case yaml.SequenceNode:
			for _, c := range n.Content {
				if err := walk(c); err != nil {
					return err
				}
			}
		case yaml.AliasNode:
			return walk(n.Alias)
		default:
			return fmt.Errorf("expected a path or a list of paths")
		}
		return nil
	}
	return walk(value)
}

// ParseConfig parses a ci.yaml file and rejects unknown keys.
func ParseConfig(data []byte) (*Config, error) {
	var cfg Config
	dec := yaml.NewDecoder(bytes.NewReader(data))
	dec.KnownFields(true)
	if err := dec.Decode(&cfg); err != nil {
		return nil, fmt.Errorf("parse ci.yaml: %w", err)
	}
	return &cfg, nil
}
