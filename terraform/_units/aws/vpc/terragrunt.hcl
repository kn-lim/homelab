locals {
  private_subnets = [for k, v in values.azs : cidrsubnet(values.cidr, 8, k)]
  public_subnets  = [for k, v in values.azs : cidrsubnet(values.cidr, 8, k + 4)]
}

inputs = {
  azs                           = values.azs
  cidr                          = values.cidr
  create_database_subnet_group  = values.create_database_subnet_group
  enable_dns_hostnames          = values.enable_dns_hostnames
  enable_dns_support            = values.enable_dns_support
  manage_default_network_acl    = values.manage_default_network_acl
  manage_default_route_table    = values.manage_default_route_table
  manage_default_security_group = values.manage_default_security_group
  name                          = values.name
  private_subnets               = local.private_subnets
  public_subnets                = local.public_subnets
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  # https://github.com/terraform-aws-modules/terraform-aws-vpc
  source = "tfr:///terraform-aws-modules/vpc/aws?version=6.9.0"
}
