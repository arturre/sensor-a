# Master node definitions
resource "aws_eks_cluster" "test" {
  name     = var.cluster-name
  role_arn = "${aws_iam_role.test-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.test-cluster.id}"]
    subnet_ids         = "${aws_subnet.test.*.id}"
  }

  depends_on = [
    "aws_iam_role_policy_attachment.test-cluster-EKSClusterPolicy",
    "aws_iam_role_policy_attachment.test-cluster-EKSServicePolicy",
  ]
}
