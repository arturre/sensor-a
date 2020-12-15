# Get all availibility zones
data "aws_availability_zones" "available" {}

# VPC definitions
resource "aws_vpc" "test" {
  cidr_block = var.vpc-cidr

  tags = "${
    map(
      "Name", "${var.cluster-name}-vpc",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

# Subnet definitions
resource "aws_subnet" "test" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "192.168.${count.index + 1}.0/24"
  vpc_id            = "${aws_vpc.test.id}"

  tags = "${
    map(
      "Name", "${var.cluster-name}-subnet${count.index + 1}",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

# Internet gateway definitions
resource "aws_internet_gateway" "test" {
  vpc_id = "${aws_vpc.test.id}"
  tags = {
    Name = "${var.cluster-name}-igw"
  }
}

# Route table definitions
resource "aws_route_table" "test" {
  vpc_id = "${aws_vpc.test.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test.id}"
  }
}

resource "aws_route_table_association" "test" {
  count = 2

  subnet_id      = "${aws_subnet.test.*.id[count.index]}"
  route_table_id = "${aws_route_table.test.id}"
}

# Master node security groups definitions
resource "aws_security_group" "test-cluster" {
  name        = "esk-test-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.test.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "esk-test-node"
  }
}

# Allow inbound traffic from local workstation's external IP to EKS master nodes.
resource "aws_security_group_rule" "test-cluster-worstation-ingress-https" {
  cidr_blocks       = ["${local.workstation-external-cidr}"]
  description       = "Allow workstation to EKS"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.test-cluster.id}"
  type              = "ingress"
}

# Worker node security group definitions
resource "aws_security_group" "test-node" {
  name        = "esk-test-node"
  description = "SG EKS Worker nodes"
  vpc_id      = "${aws_vpc.test.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
      "Name", "${var.cluster-name}-node",
      "kubernetes.io/cluster/${var.cluster-name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "test-node-ingress-self" {
  description              = "Allow traffic between workers"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.test-node.id}"
  source_security_group_id = "${aws_security_group.test-node.id}"
  type                     = "ingress"
}

resource "aws_security_group_rule" "test-cluster-ingress-node-https" {
  description              = "Allow traffic from workers to masters"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.test-cluster.id}"
  source_security_group_id = "${aws_security_group.test-node.id}"
  type                     = "ingress"
}

resource "aws_security_group_rule" "test-node-ingress-cluster" {
  description              = "Allow traffic from master to workers"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.test-node.id}"
  source_security_group_id = "${aws_security_group.test-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}
