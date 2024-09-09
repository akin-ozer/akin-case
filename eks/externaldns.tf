resource "helm_release" "externaldns" {
  name = "external-dns"

  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  namespace        = "external-dns"
  create_namespace = true
  version          = "1.14.5"
  values = [file("values/externaldns.yaml")]

  depends_on = [
    module.eks,
    kubectl_manifest.external_secret_cf,
    module.eks_blueprints_addons
  ]
}

resource "kubectl_manifest" "external_secret_cf" {
  yaml_body = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: cloudflare-akinozer-com
  namespace: external-dns
spec:
  refreshInterval: 1m
  secretStoreRef:
    name: store
    kind: ClusterSecretStore
  target:
    name: cloudflare-akinozer-com
    template:
      engineVersion: v2
      metadata:
        annotations:
          reloader.stakater.com/match: "true"
  data:
    - secretKey: token
      remoteRef:
        key: cloudflare-akinozer-com
        property: token
YAML
  depends_on = [
    kubectl_manifest.secretstore_case,
    kubectl_manifest.external_dns_ns
  ]
}

resource "kubectl_manifest" "external_dns_ns" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: external-dns
YAML
  depends_on = [
    module.eks
  ]
}