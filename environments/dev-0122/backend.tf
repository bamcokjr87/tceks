# WARNING !!! If correct key value is not used you might end up corrupting state of existing terraform state files
# key format "data/states/<gitrepo name>/<meaningful uniq deployment name or terraform-{some unique-id} >.state"
# eg :  key     = "data/states/eks-deploy-tf-code/dev-mfs-terraform-r98b.state"
# 

terraform {
  backend "s3" {
    bucket  = "tfsawsiac-prd-tfstate-files"
    key     = "data/states/eks-deploy-tf-code/terraform-0122.state"
    region  = "us-east-1"
    encrypt = true
  }
}
