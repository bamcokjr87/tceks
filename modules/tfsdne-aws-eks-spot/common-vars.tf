# AMI variables

variable "ami_owner" {
  default = "602401143452" # Amazon EKS AMI Account ID
  type    = string
}

# Launch variables
variable "ebs_volume_size" {
  default = 100
}

variable "ebs_volume_type" {
  default = "gp3"
}

variable "delete_on_termination" {
  default = true
}

variable "cluster_name" {
  default = "eks-%v-%v-cluster"
  type    = string
}

variable "worker_iam_name" {
  default = "eks-%v-%v-worker-role"
  type    = string
}

variable "master_iam_name" {
  default = "tfsaws-eks-master-role"
  type    = string
}

variable "auto_scale_group_name" {
  default = "eks-%v-%v-%v-asg"
  type    = string
}

variable "instance_profile_name" {
  default = "eks-%v-%v-instance-profile"
  type    = string
}

variable "launch_configuration_name" {
  default = "eks-%v-%v-%v-launch-configuration"
  type    = string
}

variable "master_security_group_name" {
  default = "eks-%v-%v-master-security-group"
  type    = string
}

variable "worker_security_group_name" {
  default = "eks-%v-%v-worker-security-group"
  type    = string
}

variable "aws_config_map_file_name" {
  default = "config-map-aws-auth"
  type    = string
}

variable "kube_config_file_name" {
  default = "kubeconfig"
  type    = string
}


variable "on_demand_base_capacity"{
  default = "0"

}
variable "on_demand_percentage_above_base_capacity"{
  default = "0"
}
variable "spot_allocation_strategy"{
  default = "lowest-price" 
}

variable "spot_max_price"{
  default = ""
}
variable "spot_instance_pools"{
  default = 10
} 
variable "spot_instance_type" {
  type = string
  description = "(optional) describe your variable"
  default = "t2.micro"
}

variable "ng_launch_template_name"{
  default = "ng_lt"
}
variable "ng_instance_type" {
  default = "t3.micro"
}

variable "node_group_name" {
  default = "ng_axc4"
}

variable "cluster_version" {
  description = "Specify desired EKS cluster version"
}
