############################
# IAM Roles for EKS
############################

resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_service_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids         = [aws_subnet.aks.id, aws_subnet.aks2.id]
    security_group_ids = coalescelist(var.security_group_ids, [aws_security_group.eks.id])
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
  }

  tags = var.tags
}

############################
# Node Group
############################

resource "aws_iam_role" "eks_node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_worker" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_cni" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_registry" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_node_ssm" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = [aws_subnet.aks.id, aws_subnet.aks2.id]

  scaling_config {
    desired_size = var.desired_node_count
    max_size     = var.desired_node_count
    min_size     = var.desired_node_count
  }

  instance_types = [var.node_instance_type]

  tags = var.tags
}

############################
# VPC
############################
resource "aws_vpc" "main" {
  cidr_block           = var.vnet_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpc" })
}

############################
# Internet Gateway
############################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "${var.name_prefix}-igw" })
}

############################
# Subnet
############################
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.name_prefix}-public-subnet-a"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/elb"                    = "1"
    }
  )
}
resource "aws_subnet" "aks" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.eks_subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.name_prefix}-subnet-a"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/internal-elb"           = "1"
    }
  )
}

resource "aws_subnet" "aks2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.eks_subnet_cidr2
  availability_zone = "${var.aws_region}b"

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.name_prefix}-subnet-b"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/internal-elb"           = "1"
    }
  )
}

############################
# NAT Gateway
############################

resource "aws_eip" "nat" {
  vpc = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-nat-eip" })
}

resource "aws_nat_gateway" "this" {
  subnet_id     = aws_subnet.public.id
  allocation_id = aws_eip.nat.id

  tags = merge(var.tags, { Name = "${var.name_prefix}-nat" })
}

############################
# Route Table for Public Subnet
############################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-public-rt" })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

############################
# Route Table for Private Subnets
############################

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-private-rt" })
}

resource "aws_route_table_association" "private_aks" {
  subnet_id      = aws_subnet.aks.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_aks2" {
  subnet_id      = aws_subnet.aks2.id
  route_table_id = aws_route_table.private.id
}

############################
# Security Group
############################
resource "aws_security_group" "eks" {
  name   = "${var.name_prefix}-sg"
  vpc_id = aws_vpc.main.id
  tags   = var.tags

  ingress {
    description = "Allow VPC Inbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vnet_cidr]
  }

  ingress {
    description = "Allow Load Balancer Inbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow VPC Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vnet_cidr]
  }

  egress {
    description = "Allow Internet Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}