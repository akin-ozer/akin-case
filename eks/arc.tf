data "aws_secretsmanager_secret" "arc" {
  name = "arc-token"
}

data "aws_secretsmanager_secret_version" "arc" {
  secret_id = data.aws_secretsmanager_secret.arc.id
}


resource "helm_release" "arc-set" {
  name = "actions-runner-controller"

  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart            = "gha-runner-scale-set"
  namespace        = "arc-runners"
  create_namespace = true

  set {
    name  = "githubConfigUrl"
    value = "https://github.com/akin-ozer/akin-case"
  }

  set {
    name  = "githubConfigSecret.github_token"
    value = jsondecode(data.aws_secretsmanager_secret_version.arc.secret_string)["token"]
  }

  depends_on = [
    module.eks,
    helm_release.arc
  ]
}

resource "helm_release" "arc" {
  name = "actions-runner-controller"

  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart            = "gha-runner-scale-set-controller"
  namespace        = "arc-systems"
  create_namespace = true

  depends_on = [
    module.eks
  ]
}
