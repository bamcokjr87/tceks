# To enable Private IP range for pods
Every pod and service will consume ip in the vpc, which can easily grow into 100s and 1000s of ip addresses quickly. Custom CNI configuration is used to save ips in the vpc use non-routable IP's in 100.64.x.x range for Pods. 

To setup custom cni follow instructions at 
https://docs.aws.amazon.com/eks/latest/userguide/cni-custom-network.html

# Prereqs:
Work with network team to add addtional subnets in 100.64.x.x range in the same vpc as the cluster worker nodes are installed. 
If you planning to migrate existing cluster build new nodes and migrate pods 
