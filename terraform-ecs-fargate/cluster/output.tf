output "vpc" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = aws_subnet.private.*.id
}

output "dns" {
  value = aws_lb.main.dns_name
}

output "lb_arn" {
  value = aws_lb_target_group.main.arn
}

output "security_group_id" {
  value = aws_security_group.main.id
}

output "cluster_id" {
  value = aws_ecs_cluster.main.id
}