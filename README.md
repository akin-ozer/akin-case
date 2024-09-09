# Akin Ozer case study

This repo contains all of the necessary configuration files to create a production ready Kubernetes cluster on EKS with all of the side apps:

- EFK stack to collect logs: `kibana.akinozer.com`
- Prometheus stack: `monitoring.akinozer.com`(/alertmanager, /grafana)
- ArgoCD installation: `argocd.akinozer.com`
- ExternalDNS with Cloudflare connection
- External Secrets with AWS Secrets Manager(no secrets in the repo at all, not even sealed ones)
- GitHub Actions controller and dynamic custom runners on EKS
- EKS setup includes custom VPC with custom service CIDR and Nginx Ingress with ALB setup
- Custom Helm chart for sample Java app, and the app code. `java-app.akinozer.com`

## Folder structure

```
|-- ./charts
|   |-- ./charts/monochart
|   `-- ./charts/assets
|-- ./github
|   |-- ./github/workflows
|       |-- ./github/workflows/ci.yaml
|-- ./java-app
|   |-- ./java-app/src
|   `-- ./java-app/Dockerfile
|-- ./eks
|   |-- ./eks/vpc.tf
|   |-- ./eks/provider.tf
|   |-- ./eks/argo.tf
|   |-- ./eks/externaldns.tf
|   |-- ./eks/externalsecrets.tf
|   |-- ./eks/addons.tf
|   |-- ./eks/kp.tf
|   |-- ./eks/arc.tf
|   |-- ./eks/main.tf
|   |-- ./eks/elastic.tf
|   |-- ./eks/app.tf
|   -- ./eks/values
|       |-- ./eks/values/externalsecrets.yaml
|       |-- ...
|       |-- ...
|       |-- ...
|-- ./README.md
```

## How to run it

From 0 to full running java app: Go to `/eks` folder and run `terraform apply`. That's it. Dependencies set up so it deploys even the java-app as a stage.

CI runs automatically after a file changes in main branch at `/java-app` folder.