resource "aws_eks_cluster" "cluster" {
  name = format(
    var.cluster_name,
    var.environment_identifier,
    var.random_string,
  )
  role_arn                  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.master_iam_name}"
  enabled_cluster_log_types = ["api", "audit", "controllerManager", "scheduler", "authenticator"]

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.additional_eks_sgs
  }
	
  version = var.cluster_version

  version = var.cluster_version

  tags = {
	SnowChargeCode = var.SnowChargeCode
	SnowEnvironment = var.SnowEnvironment
	SnowAppName = var.SnowAppName
	managedby = "terraform"
	sourcerepo = var.this-git-repo
  }


}

