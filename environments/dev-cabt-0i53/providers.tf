provider "aws" {
  region = var.region
  profile = var.profile
  assume_role {
    role_arn     = "arn:aws:iam::${var.this-account-id}:role/${var.assume-role}"
    session_name = "terraform"
  }
}

provider "kubernetes" {
 #host = "https://D10D5D4CB16115F1E4024FEE27EC973A.gr7.us-east-1.eks.amazonaws.com"#
  host=module.eks-cluster.cluster_endpoint
  #cluster_ca_certificate = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJVDV3UVJJczhDRG93RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBeE1qWXhPRFV5TURKYUZ3MHpOREF4TWpNeE9EVTNNREphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUQyKzNOK1lHL1BLOUZBY1IwZEI1VTR0Y0NKTmlhcEFKOTh5aUhKNUMzbkorUzJPYU1OYmR5QlNvcEUKWTZYd0MwZkNXUTFLV0hIRVJVOFlHY3hFczNqcUZYdXVwSExTb0t5S21nMnFkY3BPQXdPbGVXcWxXamQvWkZBQgpMT2pZYS9UYkdkNFRES3hGdXIxRkk1VjVnSkxpR2xLdllCR2U4ZWRpd2s1aDRVeCtFMGtRc09QTkVKYzlaZG1uCkpDWG53N09BbVVDc0Vxd2U0b213NWYwTG1UWnp4WEFlLzN2K05uM3RsejJ0dE5DbkV1RVFiNTZhRjdPM1JiMnAKMEZodWdWVW15UlFSTFhRMHBqRHNnUWhnZ1MvQlZ1VS81LzVMUitySTdUamM2T0V5c2hTTXVwMWJSNHM2Zm5GMApFNW1ITDJWMHNxQ1lzY1NoUUFtL0lFQzlKYkU5QWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJUYUtHUDdtNEI4VW5UUnozWURpSjVUVklKcnpEQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ24xSXpvekxlTgoxbVJRMFI4T2NvaG5XZW9ubUcrUSt4UGFabmU2L1FZTWpUZlpwUTJ4NUwzSm5BSnQ0RGkzVmNSTVhhSmh1YkluCkdXR0RVbWdmWU1vbFR3NjlqVEZYeU5OeGQ0bXdWRWRWLzhUYWVaYklWbnY0MW1oTmlzdm45K3p1WDBSMzFCYkwKQlNMcDllTUVOVmo1ckkvbWNCOERzNUcwaWdoOXNqQmY5U1V2ZTlGcWZqa0k3NW9Ua2V2eHdvcVpQOE95RmFxMwoxb0xLMDJaQUZQRnZVemYrQ29UeG9jRWxBODdFcnY1c2VYZ0wvWFJoTlVKOC9mUGJVMm9HMloxemtybGVVdzhTCkVmRzhCY0dNVktOT1VKMHFSL01kWTk3TlN3M29kU2Y0SVR1VnZKaXV6MytObi9GcU9ZYWprNXExYUNuVUozSDcKYlhNTng2S3lPWEpmCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K")#base64decode(module.eks-cluster.cluster_certificate_authority_data)
   cluster_ca_certificate=base64decode(module.eks-cluster.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command = "aws"

    args = ["eks","get-token", "--cluster-name",module.eks-cluster.cluster_id]
    env = {
      AWS_PROFILE = split("/",var.assume-eks-role)[1]
    }
  }
}
    
provider "helm" {
  debug = true

  kubernetes {
    host = module.eks-cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks-cluster.cluster_certificate_authority_data)
      
    exec {

      api_version = "client.authentication.k8s.io/v1beta1"
      command = "aws"

      args = ["eks","get-token", "--cluster-name",module.eks-cluster.cluster_id]

      env = {
        AWS_PROFILE = split("/",var.assume-eks-role)[1]
      }
    }
  }
}
