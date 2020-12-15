# Cluster role definitions
resource "aws_iam_role" "test-cluster" {
  name = "terraform-eks-test-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "test-cluster-EKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/EKSClusterPolicy"
  role       = "${aws_iam_role.test-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "test-cluster-EKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/EKSServicePolicy"
  role       = "${aws_iam_role.test-cluster.name}"
}

# Woker role definitions
resource "aws_iam_role" "test-node" {
  name = "terraform-eks-test-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "test-node-EKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/EKSWorkerNodePolicy"
  role       = "${aws_iam_role.test-node.name}"
}

resource "aws_iam_role_policy_attachment" "test-node-EKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/EKS_CNI_Policy"
  role       = "${aws_iam_role.test-node.name}"
}

resource "aws_iam_role_policy_attachment" "test-node-EC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/EC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.test-node.name}"
}

resource "aws_iam_role_policy_attachment" "test-node-ElasticLoadBalancingFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
  role       = "${aws_iam_role.test-node.name}"
}

resource "aws_iam_instance_profile" "test-node" {
  name = var.cluster-name
  role = "${aws_iam_role.test-node.name}"
}
