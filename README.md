
# eks-deploy-tf-code
Terraform code to deploy and maintain AWS EKS Clusters in any Environments through Terraform modules

## Getting started
Login to the ACMT box- AWS Cloud Management Tools server. Use TFS ADM account to login to the box. 
All the required tools - AWS CLI, Python packages for Centrify MFA are preinstalled and configured

* acmt1.tfs.toyota.com
* acmt2.tfs.toyota.com

### Perform Git Clone
* Perform the gitclone to import the EKS build repositories to ACMT box. 
```bash
[pandark1_adm@awva-pclif03002 github]$ git clone git@github.tfs.toyota.com:dne-cloud/eks-deploy-tf-code.git
Cloning into 'eks-deploy-tf-code'...
remote: Counting objects: 253, done.
remote: Compressing objects: 100% (92/92), done.
remote: Total 253 (delta 69), reused 111 (delta 40), pack-reused 96
Receiving objects: 100% (253/253), 59.75 MiB | 19.53 MiB/s, done.
Resolving deltas: 100% (107/107), done.
Checking out files: 100% (20/20), done.
[pandark1_adm@awva-pclif03002 github]$ ls
eks-deploy-tf-code 
```
* Run the below command to generate a 4 char random code
```bash
# generate random code using this command to be unique
cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1

[awva-pclif03001] eks-deploy-tf-code $ cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1
f283


```
* Navigate to environments directory and make a copy of the template directory to create a new environment
* Naming convention of the new directory is as follows (all lower case alpha numeric)  
	xxx-yyyyyy-zzzz
	Environment Identifier  
	xxx - 3 character Environment  
	yyyyyy - up to 6 character use case  
	Unique cluster code  
	zzzz - 4 digit random string identifier    
	Example: lab-mgmt-r2d2  
Note: There could be two clusters for the same use case if needed but clusters are differentiated with the last 4 digit random string

```bash
[pandark1_adm@awva-pclif03002 github]$ cd eks-deploy-tf-code
[pandark1_adm@awva-pclif03002 eks-deploy-tf-code]$ ls
environments  modules  README.md
[pandark1_adm@awva-pclif03002 eks-deploy-tf-code]$ cd environments/
[pandark1_adm@awva-pclif03002 environments]$ ls
Templates
[pandark1_adm@awva-pclif03002 environments]$ cp -avr templates lab-mgmt-r2d2
[pandark1_adm@awva-pclif03002 environments]$ ls
lab-mgmt-r2d2  templates
```
### Update Environment Variables
* Navigate to the new environment directory
   Files to update
	* backend.tf
	* env-vars.tf
* Replace XXXX with the 4 digit random string in backend.tf
```bash
terraform {
  backend "s3" {
    bucket  = "tfsawsiac-prd-tfstate-files"
    key     = "data/states/eks-deploy-tf-code/terraform-r2d2.state" #Replace xxxx with the 4 digit random string
```
* Update env-vars.tf with the appropriate variables for the environments
* Code is now ready for the deployment

### Perform Centrify MFA authentication to AWS
Perform Centrify MFA authentication to aws as per the instructions (Step 1 and Step 2) described in [How to use AWS CLI with assume-role method](https://myteams.toyota.com/sites/TFS-CloudOperationsCenter/SitePages/How-to-use-AWS-CLI-with-assume-role-method.aspx)

Note: For EKS cluster deployment select both iam-admin and cloud-admin role both to assume those role privileges
* xxxxxx-iam-admin role has the necessary access to create IAM roles required for ESK cluster
* xxxxxx-cloud-admin role has the necessary access to deploy EKS cluster


***Do not deploy the EKS cluster with full-admin assume role***
```bash
[pandark1_adm@awva-pclif03001 lab-dne01-kth2]$ centrify-aws-mfa-legacy
Logfile - centrify-python-aws.log
Please enter your username : pandark1_adm
Password :
Waiting for completing authentication mechanism..
Select the aws app to login. Type 'quit' or 'q' to exit
1 : tfsawsmgmt | b05fdef3-71ff-470d-b3e3-4c9dce965d5d
Calling app with key : b05fdef3-71ff-470d-b3e3-4c9dce965d5d
--------------------------------------------------------------------------------

Select a role to login. Choose one role at a time. This
selection might be displayed multiple times to facilitate
multiple profile creations.
Type 'q' to exit.

Please choose the role you would like to assume -
[ 1 ]:  arn:aws:iam::004341173277:role/tfsaws-iam-admin
[ 2 ]:  arn:aws:iam::004341173277:role/tfsaws-cloud-admin
[ 3 ]:  arn:aws:iam::004341173277:role/Everybody
Please select : 1
```
## Deploy cluster
* First initialize the terraform workspace

[pandark1_adm@awva-pclif03001 lab-mgmt-r2d2]$ ./terraform init
Initializing modules...
Initializing the backend...
Initializing provider plugins...

* Next deploy the IAM roles using iam admin role
```bash
[pandark1_adm@awva-pclif03001 lab-mgmt-r2d2]$ ./terraform apply -var profile="tfsaws-iam-admin-profile" -var assume-role="core/tfsawsdne01-iam-admin"
Refreshing Terraform state in-memory prior to plan…
module.eks-cluster.aws_iam_instance_profile.node_iam_profile: Creation complete after 0s [id=eks-lab-mgmt-r2d2-instance-profile]
module.eks-cluster.aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy: Creation complete after 0s [id=eks-lab-mgmt-r2d2-worker-role-20200304202458436800000004]
module.eks-cluster.aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly: Creation complete after 1s [id=eks-lab-mgmt-r2d2-worker-role-20200304202458392000000002]

Error: error creating EKS Cluster (eks-lab-mgmt-r2d2-cluster): AccessDeniedException:
        status code: 403, request id: cb984cdf-8f9b-42c8-a103-f5de787f9786
```
* AccessDeniedException error shown above can be ignored. Iam admin role we used in previous step doesn't have access to create the EKS cluster. 

* Next deploy the cluster using cloud admin role
```bash
[pandark1_adm@awva-pclif03001 lab-mgmt-r2d2]$ ./terraform apply
module.eks-cluster.aws_autoscaling_group.auto_scaling_group-green: Creation complete after 37s [id=eks-lab-mgmt-r2d2-green-asg]
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
Outputs:
eks-cluster = {
  "Deployed_EKS_Cluster_Name" = "eks-lab-mgmt-r2d2-cluster"
  "Generate_KUBECONFIG" = "aws eks update-kubeconfig --name  eks-lab-mgmt-r2d2-cluster --kubeconfig ~/.kube/eks-lab-mgmt-r2d2-cluster --region us-east-1 --profile tfsawsdne01-cloud-admin-profile"
}
```
* Next update kubeconfig
   Grab the kubeconfig command generated from the previous output and run it
```bash
[pandark1_adm@awva-pclif03001 lab-mgmt-r2d2]$ aws eks update-kubeconfig --name  eks-lab-mgmt-r2d2-cluster --kubeconfig ~/.kube/eks-lab-mgmt-r2d2-cluster --region us-east-1 --profile tfsawsdne01-cloud-admin-profile
Added new context arn:aws:eks:us-east-1:307377368910:cluster/eks-lab-mgmt-r2d2-cluster to /export/home/pandark1_adm/.kube/eks-lab-mgmt-r2d2-cluster
```
## Destroy cluster (If needed)
* First destroy the cluster using cloud admin role
```bash
[pandark1_adm@awva-pclif03001 lab-dne01-kth2]$ ./terraform destroy
module.lab-dne01.data.aws_availability_zones.available: Refreshing state...
module.lab-dne01.data.aws_iam_account_alias.current: Refreshing state...
module.lab-dne01.aws_iam_role.node_iam_role: Refreshing state... [id=eks-lab-dne01-kth2-worker-role]
```
	
* Next destroy the IAM roles using iam admin role
```bash
[pandark1_adm@awva-pclif03001 lab-dne01-kth2]$ ./terraform destroy -var profile="tfsaws-iam-admin-profile" -var assume-role="core/tfsawsdne01-iam-admin"
module.lab-dne01.data.aws_iam_account_alias.current: Refreshing state...
module.lab-dne01.data.aws_availability_zones.available: Refreshing state...
module.lab-dne01.data.aws_caller_identity.current: Refreshing state...
module.lab-dne01.data.aws_region.current: Refreshing state...
```

##  Sample Ambassador deployment and service files are uploaded on 9/15/2021
