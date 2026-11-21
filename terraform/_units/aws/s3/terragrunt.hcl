locals {}

inputs = {
  bucket     = values.name
  versioning = values.versioning
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  # https://github.com/terraform-aws-modules/terraform-aws-s3-bucket
  source = "tfr:///terraform-aws-modules/s3-bucket/aws?version=5.18.0"
}
