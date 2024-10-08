#
# Please check and make changes to this file before you perform terraform apply
# Depending upon the account and environment almost all variables might need to be changed
#
variable "random_string" {
  type = string
  default = "0i53"
}
variable "region" {
  default = "us-east-1"
}
variable "cluster_version" {
  default = "1.28"
}
variable "worker-node-version" {
  default = "1.28"
}
variable "this-account-id" {
  default = "670201085949" 
  type = string
}
variable "profile" {
  description = "tfsaws full admin profile"
  default     = "tfscaaws-cloud-admin"
}
variable "assume-role" {
  description = "assume-role role eg: core/tfsawspoc002-full-admin"
  default     = "core/tfscabtdev-cloud-admin"
}
variable "assume-eks-role"{
  description = "assume-role role only used in Kubernetes provider to run EKS api calls Please use cloud admin eg: core/tfsawsdne01-cloud-admin"
  default     = "core/tfscabtdev-cloud-admin"
}
variable "key_pair" {
  description = "ec2-user key-pair name"
  default = "tfscabtdev-dne-compute-virginia"
}
variable "environment_identifier" {
  type = string
  default = "dev-cabt"
}
variable "SnowEnvironment" {
  type = string
  default = "DEV"
}
variable "vpc_id" {
  type = string
  default = "vpc-04a431ba6a908db65"
}
variable "subnet_ids" {
  type = list(string)
  default = ["subnet-0d6f913dab90aec67","subnet-03c300274ff21f09f","subnet-055657aa9b448af4a"]
}
# Worker instance variables
variable "node_instance_type" {
  default = "t3.xlarge"
}
# Maxpods per worker node
variable "maxpods" {
  default = "47"
}
# AutoScalingGroup variables

variable "auto_scaling_min_size" {
  default = "1"
}

variable "auto_scaling_max_size" {
  default = "5"
}

variable "auto_scaling_desired_size" {
  default = "3"
}


# # Additional security groups -- use this option only for importing legacy clusters where mastersg exists. For new clusters keep it emtpy []
variable "additional_eks_sgs" {
  type = list(string)
  default = []
}
# Existing node sg
variable "existing_node_sg" {
  type = list(string)
  default = []
}

variable "this-git-repo" {
  default = "eks-deploy-tf-module"
}

variable "SnowAppName" {
  default = ""
}

variable "SnowChargeCode" {
  default = ""
}


variable "on_demand_base_capacity" {
  default = "0"

}
variable "on_demand_percentage_above_base_capacity" {
  default = "0"
}
variable "spot_allocation_strategy" {
  default = "capacity-optimized-prioritized"
}

variable "spot_max_price" {
  default = ""
}
variable "spot_instance_pools" {
  default = 10
}

variable "spot_instance_overrides"{
  type = map(object({
    instance_type=string
    weighted_capacity=string  
  }))
  default = {
    "override_1"= {
      instance_type = "t3.micro"
      weighted_capacity = "1",
    },
    "override_2" = {
      instance_type = "t3a.micro"
      weighted_capacity = "1",
    },
     "override_3" =  {
      instance_type = "t2.small"
      weighted_capacity = "1",
    }
  }
}

# AWS Auth Variables

variable "app_team_namespace_with_iam_creation"{
  default = {}
}

variable "app_team_namespace_without_iam_creation"{
  default = []
  type = list(
    object(
      {
        namespace=string
        iam_role=optional(string)
      }      
    )
  )
}
variable "app_team_users"{
  type= list(
    object
    (
      {
        namespace=string
        developer_role = string
        custom_ad_group_name=optional(string)
        iam_role =optional(string)
        manually_created_policies=optional(list(string))
        tf_managed_policies=optional(map(
                    object(
            {
              override_policy_documents=optional(list(string))
              policy_id=optional(string)
              source_policy_docuemnts=optional(list(string))
              statements=optional(                
                map(
                  object(
                    {
                      sid=optional(string)
                      actions=optional(list(string))
                      conditions=optional(
                        set(
                          object(
                            {
                            test=string
                            variable=string
                            values=list(string)
                            }
                          )
                        )
                      )
                      effect=optional(string)
                      not_actions=optional(list(string))
                      resources=optional(list(string))                      
                      not_resources=optional(list(string)) 
                      not_principals=optional(
                        set(
                          object(
                            {
                              type=string
                              identifiers=list(string)
                            }
                          )
                        )
                      )     
                      principals=optional(
                        set(
                          object(
                            {
                              type=string
                              identifiers=list(string)
                            }
                          )
                        )
                      )
                    }
                  )      
                )
              )
            }
          )
        )

        
        )
      }
    )
  )
  default = []
}

variable "custom_ad_group_role"{
  type = set(map(//custom_ad_group_name should be the key of map
    object({    
    managed_policy_arns = optional(list(string))
    policies = optional(map(string))
    role_name = optional(string)  
    inline_policies = optional(map(string))   
  })))
  default = []
}

variable "other_users"{
  default = {}
}




# Namespace list to be created

variable "ns-name" {
 description = "list of namespaces to be created"
 type        = list(string)

 default     = ["twistlock", "network-tools", "monitoring-tools","avi-system","dynatrace"]

}
#####


### Metrics server variables

variable "metrics_chart_name" {
  type        = string
  default     = "metrics-server"
  description = "Metrics Server Helm chart name to be installed"
}

variable "metrics_chart_release_name" {
  type        = string
  default     = "metrics-server"
  description = "Helm release name"
}

variable "metrics_chart_version" {
  type        = string
  default     = "5.9.2"
  description = "Metrics Server Helm chart version."
}

variable "metrics_chart_repo" {
  type        = string
  default     = "https://github.tfs.toyota.com/pages/dne-cloud/helm-charts/temp"
  description = "Metrics Server repository name."
}

variable "metrics_namespace" {
  type        = string
  default     = "monitoring-tools"
  description = "Kubernetes namespace to deploy Metrics Server Helm chart."
}

variable "metrics_values" {
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values."
}


## Dynatrace specific variables

variable "dynatrace_enabled" {
  type        = bool
  default     = true
  description = "Variable indicating whether deployment is enabled."
}

variable "dynatrace_chart_name" {
  type        = string
  default     = "dynatrace"
  description = "Dynatrace Helm chart name to be installed"
}

variable "dynatrace_chart_release_name" {
  type        = string
  default     = "dynatrace-operator"
  description = "Helm release name"
}

variable "dynatrace_chart_version" {
  type        = string
  default     = "0.8.2"
  description = "Dynatrace Helm chart version."
}

variable "dynatrace_chart_repo" {
  type        = string
  default     = "https://github.tfs.toyota.com/pages/SACHINB/helm-repo/dynatrace"
  description = "Dynatrace repository name."
}

variable "dynatrace_namespace" {
  type        = string
  default     = "dynatrace"
  description = "Kubernetes namespace to deploy dynatrace Helm chart."
}

variable "dynatrace_values" {
  default     = {installCRD: true}
  description = "Additional settings which will be passed to the Helm chart values."
}

### AKO variables

variable "ako_enabled" {
  type        = bool
  default     = true
  description = "Variable indicating whether AKO should be deployed"
}

variable "ako_chart_name" {
  type        = string
  default     = "ako"
  description = "AKO Helm chart name to be installed"
}

variable "ako_chart_release_name" {
  type        = string
  default     = "ako"
  description = "Helm release name"
}

variable "ako_chart_version" {
  type        = string
  default     = "1.7.2"
  description = "AKO Helm chart version."
}

variable "ako_chart_repo" {
  type        = string
  default     = "https://github.tfs.toyota.com/pages/dne-cloud/helm-charts/ako"
  description = "AKO repository name."
}

variable "ako_namespace" {
  type        = string
  default     = "avi-system"
  description = "Kubernetes namespace to deploy AKO"

}
variable "node-groups-self-managed"{
  default=[{ }]
}
variable "node-groups-managed"{
    default=[{ }]
}
variable "node_group_follow_latest_template_version" {
   type = bool
   default = false
}

variable "eks_cluster_sg" {
  default= []
}
variable "pod_subnet_config"{
  default = {}
}
