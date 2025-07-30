output "alb_dns_name" {
  description = "Public DNS of the Application Load Balancer"
  value       = aws_lb.orpheus_alb.dns_name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.orpheus_vpc.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.orpheus_public_subnet.id,
    aws_subnet.orpheus_public_subnet_2.id
  ]
}


#output "alb_security_group_id" {
# description = "ID of the ALB security group"
# value       = aws_security_group.orpheus_alb_sg.id
#}

#output "instance_security_group_id" {
# description = "ID of the instance security group"
# value       = aws_security_group.orpheus_instance_sg.id
#}

#output "ec2_instance_public_ip" {
#  description = "Public IP of the EC2 instance"
#  value       = aws_instance.orpheus_agent.public_ip
#}
