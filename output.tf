output "vpc_id" {
  value = module.vpc.vpc_id
}
output "igw_id" {
  value = module.vpc.igw_id
}
output "public_subnet_ids" {
  value = module.dynamic_subnets.public_subnet_ids
}
output "private_subnet_ids" {
  value = module.dynamic_subnets.private_subnet_ids
}
output "eks_cluster_name" {
  value = module.eks_cluster.eks_cluster_id
}

output "jenkins_server_ip" {
  value = module.jenkins_server.private_ip
}
output "jenkins_server_id" {
  value = module.jenkins_server.id

