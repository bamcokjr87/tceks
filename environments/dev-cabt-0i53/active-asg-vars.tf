# Select one of the Autoscaling groups to be active for new cluster install
# If managing existing cluster check which asg is active before making any change. 
# This file will be using to replace eks worker nodes for patching(replacing with new nodes), maintenance, new features etc. 

variable "activate-blue-asg" {
   type = string
   default = "false"
}

variable "activate-green-asg" {
   type = string
   default = "false"
}
variable "activate-blue-asg-spot" {
   type = string
   default = "false"
}

variable "activate-green-asg-spot" {
   type = string
   default = "false"
}

variable "activate-blue-asg-spot-managed" {
   type = string
   default = "false"
}

variable "activate-green-asg-spot-managed" {
   type = string
   default = "false"
}

variable "activate-blue-asg-managed-ondemand" {
   type = string
   default = "false"
}

variable "activate-green-asg-managed-ondemand" {
   type = string
   default = "false"
}

variable "activate-blue-asg-spot-managed-stateful" {
   type = string
   default = "false"
}

variable "activate-green-asg-spot-managed-stateful" {
   type = string
   default = "false"
}

