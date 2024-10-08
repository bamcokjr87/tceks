node-groups-managed={
   "green-ondemand"= {  
    capacity_type="ondemand"
    auto_scaling_desired_size = 3
    auto_scaling_max_size = 6
    auto_scaling_min_size = 1
    template_version = 1
   }
}

node-groups-self-managed={
#   "blue-self"={
#    capacity_type="ondemand"
#    auto_scaling_desired_size = 3
#    auto_scaling_max_size = 5
#    auto_scaling_min_size =1    
#   }
}

  app_team_users=[  
  # {
  #   namespace="k8s-dev-diceqp-wb0e"
  #   developer_role = "tfseksdeveloperscluster-role"
  #   #manually_created_policies = ["tfsawsdne01-eks-lab-olu10-s3-policy"]
  #   tf_managed_irsa ={      
  #   }    
  #   tf_managed_policies ={    
  #   }
  # }
 ]

#app_team_namespace_without_iam_creation section start/////////////////////////////////////////////////////////////////////////////////////////////////////
 #This list creates a namespace without an IAM Role creating IAM role should be manually done.
 #For namespace k8s-dev-diceqp-wb0e
 #  The below entry will be added to the aws-auth config map
      # "userarn": "arn:aws:iam::486315260960:role/mfin1awssubprod-eks-k8s-dev-diceqp-role"
      # "username": "k8s-dev-diceqp"
 app_team_namespace_without_iam_creation=[
     {namespace = "k8s-dev-tccijz-3dpd"}
   #iam_role = ""  
 ]
#app_team_namespace_without_iam_creation section complete/////////////////////////////////////////////////////////////////////////////////////////////////////

app_team_namespace_with_iam_creation = [
#   namespace = "k8s-poc-airflow"
]


eks_cluster_sg = []
