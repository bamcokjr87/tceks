data "aws_ami" "eks_node_ami" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.cluster.version}-v*"]
  }

  most_recent = true
  owners      = [var.ami_owner] # Amazon EKS AMI Account ID
}

