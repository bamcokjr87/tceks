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

accountid=$(aws sts get-caller-identity --profile $profile | jq -r .Account)

echo -e "\n"
echo "Modify :: Installing Cluster Autoscaler"
sed -i -e "s|{{cluster}}|${cluster}|g" ../standard-eks-config-files/cluster-autoscaler/cluster-autoscaler-autodiscover.yaml
kubectl apply -f ../standard-eks-config-files/cluster-autoscaler/cluster-autoscaler-autodiscover.yaml
kubectl annotate serviceaccount cluster-autoscaler  -n kube-system  eks.amazonaws.com/role-arn=arn:aws:iam::$accountid:role/AmazonEKSClusterAutoscalerRole

kubectl patch deployment cluster-autoscaler -n kube-system  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'

kubectl set image deployment cluster-autoscaler  -n kube-system  cluster-autoscaler=artifactory.tfs.toyota.com/dnecloud-docker-dev-local/cluster-autoscaler
