resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "6.10.0"

  values = [file("values/argocd.yaml")]

  depends_on = [
    module.eks,
    helm_release.externaldns
  ]
}