module "memcached" {
  source = "../../terraform-modules/massdriver/aws-elasticache-memcached"
  md_metadata = var.md_metadata
}
