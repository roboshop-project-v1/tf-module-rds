resource "aws_db_subnet_group" "rds" {
  name       = "${local.name_prefix}-subnet-group"
  subnet_ids = var.subnet_ids
  tags = var.tags
}


resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-sg"
  description = "${local.name_prefix}-sg"
  vpc_id      = var.vpc_id
  tags = var.tags
}



resource "aws_security_group_rule" "rds" {
  type              = "ingress"
  from_port         = var.from_port
  to_port           = var.to_port
  protocol          = "tcp"
  cidr_blocks       = var.sg_ingress_cidr
  security_group_id = aws_security_group.rds.id
}


resource "aws_vpc_security_group_egress_rule" "rds" {
  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_db_parameter_group" "rds" {
  name   = "${local.name_prefix}-pg"
  family = var.engine_family
}


resource "aws_rds_cluster" "rds" {
  cluster_identifier      = "${local.name_prefix}-cluster"
  engine                  = var.engine
  engine_version          = var.engine_version
  database_name           = data.aws_ssm_parameter.rds_master_database.value
  master_username         = data.aws_ssm_parameter.rds_master_username.value
  master_password         = data.aws_ssm_parameter.rds_master_password.value
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  db_subnet_group_name = aws_db_subnet_group.rds.name
  db_instance_parameter_group_name = aws_db_parameter_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  tags = var.tags
  skip_final_snapshot     = var.skip_final_snapshot
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = var.instance_count
  identifier         = "${local.name_prefix}-cluster-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.rds.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.rds.engine
  engine_version     = aws_rds_cluster.rds.engine_version
}