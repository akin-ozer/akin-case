module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "akin-case"
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  cluster_service_ipv4_cidr = "10.200.0.0/16"
  control_plane_subnet_ids  = module.vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3a.large"]
  }

  eks_managed_node_groups = {
    main = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3a.large"]

      min_size     = 6
      max_size     = 10
      desired_size = 6
    }
  }

  enable_cluster_creator_admin_permissions = true
  create_kms_key = false
  cluster_encryption_config = {}
  create_cloudwatch_log_group = false

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}