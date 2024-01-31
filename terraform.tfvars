#vpc varibales
vpc_name                         = "production-vpc"
cidr_block                       = "10.5.0.0/16"
assign_generated_ipv6_cidr_block = true
dns_hostnames_enabled            = true
dns_support_enabled              = true
default_security_group_deny_all  = true

#subent varibales
availability_zones = ["us-east-2a", "us-east-2b"]
nat_gateways_count = 1
single_nat         = true


#keypair

aws_key_pair_name   = "production_key"
ssh_public_key_path = "./secrets"
generate_ssh_key    = true




#eks variables

region                  = "us-east-1"
kubernetes_version      = "1.28"
eks_cluster_name        = "production-cluster"
oidc_provider_enabled   = true
endpoint_private_access = true

#eks node group variables

eks_nodegroup_instance_type = ["t3.medium"]
desired_size                = 1
min_size                    = 1
max_size                    = 2
capacity_type               = "ON_DEMAND"
cluster_autoscaler_enabled  = true

#server variables

ec2_name                          = "server"
ec2_instance_type                 = "t2.medium"
ec2_ami                           = "ami-0bddc40b31973ff95"
ami_owner                         = "099720109477"
ec2_create_default_security_group = true
ec2_allowed_ports                 = [22, 8080]

