resource "aws_ssm_parameter" "app_secret" {
  name  = "/${var.project_name}/${var.environment}/APP_SECRET"
  type  = "SecureString"
  value = var.app_secret_value
  tags  = local.tags
}
