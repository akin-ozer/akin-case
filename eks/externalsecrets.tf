data "aws_secretsmanager_secret" "external_secrets" {
  name = "external-secrets-config"
}

data "aws_secretsmanager_secret_version" "external_secrets" {
  secret_id = data.aws_secretsmanager_secret.external_secrets.id
}

resource "kubectl_manifest" "secretstore_case" {
  yaml_body = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: store
spec:
  provider:
    aws:
      service: SecretsManager
      region: eu-west-1
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: awssm-secret
            key: access-key
            namespace: external-secrets
          secretAccessKeySecretRef:
            name: awssm-secret
            key: secret-access-key
            namespace: external-secrets
YAML
  depends_on = [
    kubernetes_secret.aws_creds,
    helm_release.externalsecrets
  ]
}

resource "helm_release" "externalsecrets" {
  name = "external-secrets"

  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  version          = "0.10.2"

  values = [file("values/externalsecrets.yaml")]

  depends_on = [
    module.eks,
    kubernetes_secret.aws_creds
  ]
}


resource "kubernetes_secret" "aws_creds" {
  metadata {
    name      = "awssm-secret"
    namespace = "external-secrets"
  }

  data = {
    access-key        = jsondecode(data.aws_secretsmanager_secret_version.external_secrets.secret_string)["access-key"]
    secret-access-key = jsondecode(data.aws_secretsmanager_secret_version.external_secrets.secret_string)["secret-access-key"]
  }

  depends_on = [
    module.eks,
    kubectl_manifest.external_secrets_ns
  ]
}

resource "kubectl_manifest" "external_secrets_ns" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: external-secrets
YAML
  depends_on = [
    module.eks,
    module.eks_blueprints_addons
  ]
}