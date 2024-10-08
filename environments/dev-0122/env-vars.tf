#
# Please check and make changes to this file before you perform terraform apply
# Depending upon the account and environment almost all variables might need to be changed
#
variable "random_string" {
  type = string
  default = "0122"
}
variable "environment_identifier" {
  type = string
  default = "dev"
}
variable "region" {
  default = "us-east-1"
}
variable "this-account-id" {
  default = "009754696474"
  type = string
}
variable "profile" {
  description = "tfsaws cloud admin profile"
  default     = "tfsaws-cloud-admin"
}
variable "assume-role" {
  description = "assume-role role eg: core/tfsawsdne01-cloud-admin"
  default     = "core/tfsawssubprod-cloud-admin"
}
variable "key_pair" {
  description = "ec2-user key-pair name"
  default = "tfsawssubprod-dne-compute-virginia"
}
variable "SnowEnvironment" {
  type = string
  default = "Development"
}
variable "map-migrated" {
  type = string
  default = "d-server-03m7zv43tgtvf0"
}
variable "MPE" {
  type = string
  default = "MPE22167"
}
variable "SnowChargeCode" {
  type = string
  default = "050096-FACT0903"
}
variable "SnowAppName" {
  type = string
  default = "Kubernetes Infrastructure"
}
variable "vpc_id" {
  type = string
  default = "vpc-09c5d8ab78006231d"
}
variable "subnet_ids" {
  type = list(string)
  default = ["subnet-0a6b5a733c922c9a7","subnet-08100a57e400151e0","subnet-02ecb25506bbafca8"]
}

# Worker instance variables
# Worker node instance size - default size for prod and subprod = r5.2xlarge, for lab t3.medium
variable "node_instance_type" {
  default = "r5.4xlarge"
}
# Maxpods per worker node
# Refer https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#AvailableIpPerENI
# formula = maxPods = (number of interfaces - 1) * (max IPv4 address per interface - 1) + number of deamonsets with host networking . (ds=6)
variable "maxpods" {
  default = "209"
}

# AutoScalingGroup variables

variable "auto_scaling_min_size" {
  default = "3"
}

variable "auto_scaling_max_size" {
  default = "12"
}

variable "auto_scaling_desired_size" {
  default = "3"
}


# Additional security groups -- use this option only for importing legacy clusters where mastersg exists. For new clusters keep it emtpy []
variable "additional_eks_sgs" {
  type = list(string)
  default = ["sg-04f140fd2557faaff"]
}
# Existing node sg
variable "existing_node_sg" {
  type = list(string)
  default = []
}

variable "this-git-repo" {
  default = "eks-deploy-tf-code"
}

variable "cluster_version" {
  default = "1.28"
}
