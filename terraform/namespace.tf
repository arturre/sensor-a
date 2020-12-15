

resource "kubernetes_namespace" "eks_namespace" {
  metadata {
    labels = {
      isto-injection = local.enable-istio
    }
    name = "test"
  }
}
