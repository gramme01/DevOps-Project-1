output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.dns_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}
output "cluster_name" {
  value = module.ecs.cluster_name
}
output "service_name" {
  value = module.ecs_service.name
}