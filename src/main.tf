module "memcached" {
  source = "../../terraform-modules/massdriver/aws-elasticache-memcached"
  md_metadata = var.md_metadata
  replicas = var.replicas
  cluster_mode_enabled = var.cluster_mode_enabled
  cidr = var.vpc.data.infrastructure.cidr
  internal_subnets = var.vpc.data.infrastructure.internal_subnets
  private_subnets = var.vpc.data.infrastructure.private_subnets
  vpc_id = var.vpc.data.infrastructure.arn
  node_groups = var.node_groups
  secure = var.secure
  subnet_type = var.subnet_type
  memcached_version = var.memcached_version
  node_type = var.node_type
}

