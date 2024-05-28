locals {
  name_prefix = "${var.env}-rds"
  tags = merge(var.tags , {tf-module-name = "rds"},{env = var.env})
}