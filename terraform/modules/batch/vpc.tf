variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c"]
}

# VPC
resource "aws_vpc" "batch_vpc" {
  cidr_block           = var.vpc_cidr
  
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# プライベートサブネット
resource "aws_subnet" "batch_private_subnet" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.batch_vpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
}

# プライベートルートテーブル
resource "aws_route_table" "batch_private_route_table" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.batch_vpc.id
}

# プライベートルートテーブルの関連付け
resource "aws_route_table_association" "batch_private_route_table_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.batch_private_subnet[count.index].id
  route_table_id = aws_route_table.batch_private_route_table[count.index].id
}

# CloudWatch Logs用のVPCエンドポイント
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.batch_vpc.id
  service_name        = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.batch_private_subnet[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true
}

# ECR API用のVPCエンドポイント
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.batch_vpc.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.batch_private_subnet[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true
}

# ECR Docker用のVPCエンドポイント
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.batch_vpc.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.batch_private_subnet[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true
}

# S3用のVPCエンドポイント（ゲートウェイタイプ）
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.batch_vpc.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.batch_private_route_table[*].id
}