module "vpc" {
  source = "./modules/terraform-vpc-aws"

  name                             = var.vpc_name
  ipv4_primary_cidr_block          = var.cidr_block
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block
  dns_hostnames_enabled            = var.dns_hostnames_enabled
  dns_support_enabled              = var.dns_support_enabled
  default_security_group_deny_all  = var.default_security_group_deny_all

  tags = {
    Environment   = "production"
    Resource_type = "vpc"
    Terraform     = "true"
  }
}


module "dynamic_subnets" {
  source             = "./modules/terraform-dynamic-subnet-aws"

  name               = var.vpc_name
  availability_zones = var.availability_zones
  vpc_id             = module.vpc.vpc_id
  igw_id             = module.vpc.igw_id
  nat_gateways_count = var.nat_gateways_count
  single_nat         = var.single_nat
  cidr_block         = var.cidr_block

  tags = {
    Environment   = "production"
    Resource_type = "subnets"
    Terraform     = "true"
  }
}


module "aws_key_pair" {
  source              = "./modules/terraform-aws-key-pair"

  name                = var.aws_key_pair_name
  ssh_public_key_path = var.ssh_public_key_path
  generate_ssh_key    = var.generate_ssh_key
}








module "eks_cluster" {
  source = "./modules/terraform-aws-eks-cluster"

  name                    = var.eks_cluster_name
  region                  = var.region
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.dynamic_subnets.private_subnet_ids
  kubernetes_version      = var.kubernetes_version
  endpoint_private_access = var.endpoint_private_access
  allowed_cidr_blocks     = module.dynamic_subnets.private_subnet_cidrs
  oidc_provider_enabled   = var.oidc_provider_enabled
  #workers_role_arns          = [module.eks_node_group.eks_node_group_role_arn]
  workers_security_group_ids = []

  tags = {
    Environment   = "production"
    Resource_type = "eks"
    Terraform     = "true"
  }

}


module "eks_node_group" {
  source = "./modules/terraform-aws-eks-node-group"

  cluster_name               = module.eks_cluster.eks_cluster_id
  name                       = var.eks_cluster_name
  subnet_ids                 = module.dynamic_subnets.private_subnet_ids
  instance_types             = var.eks_nodegroup_instance_type
  capacity_type              = var.capacity_type
  desired_size               = var.desired_size
  min_size                   = var.min_size
  max_size                   = var.max_size
  kubernetes_version         = var.kubernetes_version
  cluster_autoscaler_enabled = var.cluster_autoscaler_enabled
  node_role_policy_arns      = ["arn:aws:iam::aws:policy/SecretsManagerReadWrite"]

  tags = {
    Environment   = "production"
    Resource_type = "eks"
    Terraform     = "true"
  }
  depends_on = [module.eks_cluster]
}


module "runner_server" {
  source = "./modules/terraform-aws-ec2-bastion-server"

  name                          = var.ec2_name
  vpc_id                        = module.vpc.vpc_id
  ami                           = var.ec2_ami
  subnets                       = module.dynamic_subnets.private_subnet_ids[0]
  instance_type                 = var.ec2_instance_type
  key_name                      = module.aws_key_pair.key_name
  user_data_template            = var.ec2_user_data_template
  create_default_security_group = var.create_default_security_group
  allowed_ports                 = var.ec2_allowed_ports
  allowed_ports_udp             = var.ec2_allowed_ports_udp
  ingress_cidr_blocks           = [module.vpc.vpc_cidr_block]

  tags = {
    Environment   = "production"
    Resource_type = "ec2"
    Terraform     = "true"
    server        = "jenkins_server"
  }
  depends_on = [module.bastion]
}


