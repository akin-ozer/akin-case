resource "helm_release" "java_app" {
  name = "java-app"

  repository       = "https://raw.githubusercontent.com/akin-ozer/akin-case/main"
  chart            = "monochart"
  namespace        = "production"
  create_namespace = true
  version          = "1.0.0"

  values = [file("values/java-app.yaml")]

  depends_on = [
    module.eks,
    helm_release.externaldns
  ]
}