#!/bin/bash

# Developed by DNE Cloud 
# Version : 2020-03
# Intialiaze newly built eks cluster. Running this script on existing cluster might cause issues. 
#

set -e
while [ $# -gt 0 ]; do
  case "$1" in
    --cluster-name=*)
      cluster="${1#*=}"
      ;;
    --region=*)
      region="${1#*=}"
      ;;
    --profile=*)
      profile="${1#*=}"
      ;;
    * ) 
      printf "********************************************************************************************************************************************\n"
      printf "* Error: Invalid arguments. Please provide --account-id=<accounid> --account-alias=<account-alias> --profile=<awsprofile per ~/.aws/config>*\n"
      printf "********************************************************************************************************************************************\n"
      exit 1
  esac
  shift
done

# Validation
aws sts get-caller-identity --profile $profile > /dev/null


accountid=$(aws sts get-caller-identity --profile $profile | jq -r .Account)
accountalias=$(aws iam list-account-aliases --profile $profile|jq -r .AccountAliases[])
echo "Validation :: Profile $profile is valid for AWS Account ID: $accountid and Account Alias: $accountalias"
echo "Validation :: Checking if eks cluster : $cluster exists."

aws eks describe-cluster --name $cluster --profile $profile --region $region > /dev/null

clusterinfo=$(aws eks describe-cluster --name $cluster --profile $profile --region $region|jq -r .cluster)

echo "Validation :: Found cluster with name: `echo $clusterinfo|jq -r .name`"
echo "Validation :: Cluster status: `echo $clusterinfo|jq -r .status`"
echo "Validation :: Cluster version: `echo $clusterinfo|jq -r .version`"

# Generating KUBECONFIG file

echo -e "\n"
echo "Validation :: Generating KUBECONFIG file ~/.kube/$cluster"
aws eks update-kubeconfig --kubeconfig ~/.kube/$cluster --region $region --name $cluster --profile $profile
export KUBECONFIG=~/.kube/$cluster

echo -e "\n"
echo "Validation :: Validating access to cluster"
kubectl get svc 

echo -e "\n"
echo "Validation :: kubectl and cluster versions"
kubectl version --short

echo -e "\n"
echo "Validation :: Verfiying if aws-auth configmap exists"
check_auth=$(kubectl get configmap -n kube-system |grep ^aws-auth | wc -l)
if [ $check_auth -eq 0 ]; then
	echo "Validation :: No aws-auth configmap exists. Applying plain configmap with iam-role associated with $cluster nodes"
	#curl -s -o aws-auth-cm.yaml https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-11-15/aws-auth-cm.yaml
	cp ../../../standard-eks-config-files/aws-auth-configmap.yaml .
	eks_worker_iam_role=$(aws iam list-roles --profile $profile|jq -r '.Roles[]|.Arn' |grep "$(echo $cluster|awk -F'-' '{print $(NF-1)}')-worker-role")
	sed -i -e "s|<ARN of instance role (not instance profile)>|${eks_worker_iam_role}|g" aws-auth-configmap.yaml
	sed -i -e "s|{{accountid}}|${accountid}|g" aws-auth-configmap.yaml
	sed -i -e "s|{{accountalias}}|${accountalias}|g" aws-auth-configmap.yaml

else
	echo -e "\n"
	echo "WARNING :: aws-auth configmap exists. Delete the existing aws-auth configmap, if you want to reset existing configmap"
	echo "WARNING :: Command to delete configmap : kubectl delete configmap aws-auth -n kube-system"
	echo "WARNING :: Note this reset any existing authentication already provided. Execute this if you are 100% sure"
#	exit
fi

echo "Modify :: Applying plain configmap with iam-role associated with $cluster nodes"
echo "Modify :: IAM role associated with $cluster nodes: $eks_worker_iam_role"
kubectl apply -f aws-auth-configmap.yaml

# standard storage class creation

echo -e "\n"
echo "Modify :: Applying EBS Storage Class - standard"
mkdir -p storageclass
cp ../../../standard-eks-config-files/storageclass/storage-class-ebs.yaml storageclass/
ebs_key_alias="${accountalias}-ebs-key"
ebs_key_id=$(aws kms list-aliases --region $region --profile $profile --output text |grep ${ebs_key_alias}|awk '{print $NF}')
ebs_key_arn=$(aws kms describe-key --key-id ${ebs_key_id} --query 'KeyMetadata.Arn' --output text --region $region --profile $profile)
sed -i -e "s|{{EBS_KMS_KEY_ARN}}|${ebs_key_arn}|g" storageclass/storage-class-ebs.yaml
kubectl apply -f storageclass/storage-class-ebs.yaml
check_gp2sc=$(kubectl get sc gp2|grep ^gp2|wc -l)
if [ $check_gp2sc -gt 0 ]; then
	kubectl patch sc gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
	kubectl delete sc gp2
fi
kubectl patch sc standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
echo "Validation :: Applied storage class"
echo "Validation :: kubectl describe sc standard"
kubectl describe sc standard



# Tag LB subnets

echo -e "\n"
echo "Modify :: Identifying Subnets for use with Internal LoadBalancing"

vpcid=$(aws eks describe-cluster --name $cluster --region=$region --profile=$profile | jq -r '.cluster.resourcesVpcConfig.vpcId')
subnets=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${vpcid}" --region=$region --profile=$profile --query 'Subnets[].{SubnetId:SubnetId,Name:Tags[?Key==`Name`]|[0].Value}' --output text|grep "\-LB-" |awk '{print $NF}')

echo "Modify :: Found LB Subnets:  $subnets"
echo "Modify :: Adding tags to LB  Subnets"
aws ec2 create-tags --resource $subnets --tags Key="kubernetes.io/role/internal-elb",Value=1 Key="kubernetes.io/cluster/${cluster}",Value=owned --region=$region --profile=$profile

# install efs driver, create efs storageclass

echo -e "\n"
echo "Modify :: Adding EFS Driver and EFS Storage class"

git clone https://github.tfs.toyota.com/dne-cloud/aws-efs-csi-driver-master.git
cd aws-efs-csi-driver-master/deploy/kubernetes/overlays/stable
kubectl apply -k .
cd -
rm -rf aws-efs-csi-driver-master

cp ../../../standard-eks-config-files/storageclass/storage-class-efs.yaml storageclass/
kubectl apply -f storageclass/storage-class-efs.yaml

echo "Validation :: Applied storage class"
echo "Validation :: kubectl describe sc efs-sc"
kubectl describe sc efs-sc


# create ns - twistlock,monitoringtools,management

echo -e "\n"
echo "Modify :: Creating namespaces: twistlock network-tools monitoring-tools"

mkdir -p ns
cp ../../../standard-eks-config-files/ns/* ns/
kubectl apply -f ns/tfs-standard-namespaces.yaml


# create standard cluster role bindings

echo -e "\n"
echo "Modify :: Adding predefined RBAC Configs"

mkdir -p rbac
cp ../../../standard-eks-config-files/rbac/* rbac/
echo "Modify :: Applying tfsekstoolscluster-role.yaml"
sed -i -e "s|{{accountalias}}|${accountalias}|g" rbac/tfsekstoolscluster-role.yaml
kubectl apply -f rbac/tfsekstoolscluster-role.yaml

echo "Modify :: Applying tfseksdeveloperscluster-role.yaml"
sed -i -e "s|{{accountalias}}|${accountalias}|g" rbac/tfseksdeveloperscluster-role.yaml
kubectl apply -f rbac/tfseksdeveloperscluster-role.yaml

echo "Modify :: Applying network-twistlock-rbac.yaml"
sed -i -e "s|{{accountalias}}|${accountalias}|g" rbac/network-twistlock-rbac.yaml
kubectl apply -f rbac/network-twistlock-rbac.yaml

echo "Modify :: Applying network-admin-rbac.yaml"
sed -i -e "s|{{accountalias}}|${accountalias}|g" rbac/network-admin-rbac.yaml
kubectl apply -f rbac/network-admin-rbac.yaml

echo "Modify :: Applying monitoring-admin-rbac.yaml"
sed -i -e "s|{{accountalias}}|${accountalias}|g" rbac/monitoring-admin-rbac.yaml
kubectl apply -f rbac/monitoring-admin-rbac.yaml

# Enable custom eni config for secondary cidr

#echo -e "\n"
#echo "Modify :: Enabling Custom ENI Configuration"

#kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
#mkdir eniconfig
#cp ../../../standard-eks-config-files/eni/* eniconfig/
#kubectl apply -f eniconfig/ENIConfig.yaml






# install fluentd, filebeat

mkdir -p fluentd
cp ../../../standard-eks-config-files/fluentd/fluentd.yaml fluentd/
sed -i -e "s|{{clustername}}|${cluster}|g" fluentd/fluentd.yaml
kubectl apply -f fluentd/fluentd.yaml




