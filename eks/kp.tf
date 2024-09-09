resource "helm_release" "kp" {
  name = "kube-prometheus-stack"

  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "35.5.1"
  namespace        = "kube-prometheus-stack"
  create_namespace = true
  values = [file("values/kp.yaml")]

  depends_on = [
    module.eks,
    helm_release.externaldns
  ]
}