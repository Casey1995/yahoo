# resource "aws_vpc" "vpc" {
#   cidr_block = "10.0.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true
#   tags = merge(var.map_tags, {"Name" = "VPC"})
# }

# data "aws_availability_zones" "available" {
#   state = "available"
# }

# resource "aws_subnet" "my_subnet" {
#   count                   = 3
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
#   map_public_ip_on_launch = true
#   availability_zone       = element(data.aws_availability_zones.available.names, count.index)
#   tags = {
#     Name = "MySubnet-${count.index}"
#   }
# }

# resource "aws_route_table" "my_route_table" {
#   vpc_id = aws_vpc.vpc.id
#   tags = {
#     Name = "MyRouteTable"
#   }
# }

# resource "aws_route_table_association" "my_route_table_assoc" {
#   count          = length(aws_subnet.my_subnet)
#   subnet_id      = aws_subnet.my_subnet[count.index].id
#   route_table_id = aws_route_table.my_route_table.id
# }

# resource "aws_vpc_endpoint" "s3_endpoint" {
#   vpc_id       = aws_vpc.vpc.id
#   service_name = "com.amazonaws.us-east-1.s3"
#   vpc_endpoint_type = "Gateway"

#   route_table_ids = [aws_route_table.my_route_table.id]

#   tags = merge(var.map_tags, {"Name" = "S3Endpoint"})
# }

# resource "aws_vpc_endpoint" "dynamo_endpoint" {
#   vpc_id       = aws_vpc.vpc.id
#   service_name = "com.amazonaws.us-east-1.dynamodb"
#   vpc_endpoint_type = "Gateway"

#   route_table_ids = [aws_route_table.my_route_table.id]

#   tags = merge(var.map_tags, {"Name" = "DynamodbEndpoint"})
# }

# resource "aws_vpc_endpoint" "api_endpoint" {
#   vpc_id       = aws_vpc.vpc.id
#   service_name = "com.amazonaws.us-east-1.execute-api"
#   vpc_endpoint_type = "Interface"

# #   route_table_ids = [aws_route_table.my_route_table.id]

#   tags = merge(var.map_tags, {"Name" = "APIEndpoint"})
# }

# ############################################################################
# resource "aws_security_group" "allow_tls" {
#   name        = "allow_tls"
#   description = "Allow TLS inbound traffic and all outbound traffic"
#   vpc_id      = aws_vpc.vpc.id
#   tags = merge(var.map_tags, {"Name" = "vpc-SG"})
# }

# resource "aws_security_group_rule" "ingress1" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks       = [aws_vpc.vpc.cidr_block]
#   security_group_id = aws_security_group.allow_tls.id
# }

# resource "aws_security_group_rule" "ingress2" {
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = [aws_vpc.vpc.cidr_block]
#   security_group_id = aws_security_group.allow_tls.id
# }

# resource "aws_security_group_rule" "egress" {
#   type              = "egress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "tcp"
#   cidr_blocks       = [aws_vpc.vpc.cidr_block]
#   security_group_id = aws_security_group.allow_tls.id
# }
