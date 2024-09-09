resource "helm_release" "elasticsearch" {
  name = "elasticsearch"

  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "elasticsearch"
  namespace        = "elasticsearch"
  create_namespace = true
  values = [file("values/elastic.yaml")]

  depends_on = [
    module.eks,
    helm_release.externaldns
  ]
}

resource "helm_release" "fluentbit" {
  name = "fluent-bit"

  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "fluent-bit"
  namespace        = "fluent-bit"
  create_namespace = true
  values = [file("values/fluentbit.yaml")]

  depends_on = [
    module.eks,
    helm_release.elasticsearch
  ]
}

resource "helm_release" "kibana" {
  name = "kibana"

  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "kibana"
  namespace        = "kibana"
  create_namespace = true
  values = [file("values/kibana.yaml")]

  depends_on = [
    module.eks,
    helm_release.elasticsearch
  ]
}
