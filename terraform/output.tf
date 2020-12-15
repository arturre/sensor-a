# Output a configMap to join worker node into the cluster
locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.test-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.test.endpoint}
    certificate-authority-data: ${aws_eks_cluster.test.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster-name}"
KUBECONFIG
}

resource "local_file" "config_map_aws_auth" {
  content  = "${local.config_map_aws_auth}"
  filename = "${path.module}/aws_auth-configmap.yaml"
}
//kubeconfig file for kubectl
resource "local_file" "kubeconfig" {
  content  = "${local.kubeconfig}"
  filename = "${path.module}/kubeconfig"
}
