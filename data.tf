data "aws_ssm_parameter" "rds_master_username" {
  name = "rds.${var.env}.master_username"
}

data "aws_ssm_parameter" "rds_master_password" {
  name = "rds.${var.env}.master_password"
}


data "aws_ssm_parameter" "rds_master_database" {
  name = "rds.${var.env}.master_database"
}