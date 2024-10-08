# Do not make any changes to the file contents and run same as sample command :

# ./run-cloudwatch-agent.sh --cluster-name=eks-dco-kx1z-cluster --region=us-east-1 --profile=tfsawsdne01-cloud-admin

# --------------------------------------------------------------------------------------------------------
#!/bin/bash

# Developed by DNE Cloud 
# Version : 2020-07
# Install CloudWatch container insight   
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
# --------------------------------------------------------------------------------------------------------

# Create a namespace for CloudWatch


kubectl apply -f ../standard-eks-config-files/cloudwatch/cwagent-namespace.yaml

# Create a service account in the cluster

kubectl apply -f ../standard-eks-config-files/cloudwatch/cwagent-service-account.yaml

# Create a ConfigMap for the CloudWatch agent

sed -i -e "s|{{cluster_name}}|${cluster}|g" ../standard-eks-config-files/cloudwatch/cwagent-configmap.yaml
sed -i -e "s|{{region}}|${region}|g" ../standard-eks-config-files/cloudwatch/cwagent-configmap.yaml

kubectl apply -f ../standard-eks-config-files/cloudwatch/cwagent-configmap.yaml

# Deploy the CloudWatch agent as a DaemonSet

kubectl apply -f ../standard-eks-config-files/cloudwatch/cwagent-daemonset.yaml

# Create a ConfigMap named cluster-info with the cluster name and the Region to send logs
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
kubectl create configmap fluent-bit-cluster-info \
--from-literal=cluster.name=${cluster} \
--from-literal=http.server=${FluentBitHttpServer} \
--from-literal=http.port=${FluentBitHttpPort} \
--from-literal=read.head=${FluentBitReadFromHead} \
--from-literal=read.tail=${FluentBitReadFromTail} \
--from-literal=logs.region=${region} -n amazon-cloudwatch

# Deploy Fluent Bit as a DaemonSet

kubectl apply -f ../standard-eks-config-files/fluentbit/fluentbit.yaml

## Login to Console and confirm if logs are created now
