output "Deployed_EKS_Cluster_Name" {
  value = aws_eks_cluster.cluster.name
}
output "Generate_KUBECONFIG" {
  description = "Run the below command in case you are deploying the cluster for the first time or to get the KUBECONFIG file updated"
  value       = "aws eks update-kubeconfig --name  ${aws_eks_cluster.cluster.name} --kubeconfig ~/.kube/${aws_eks_cluster.cluster.name} --region ${var.region} --profile ${data.aws_iam_account_alias.current.account_alias}-cloud-admin-profile"
}

output "ASG_Command_output" {
  value = data.local_file.local_exec_output.content
}



