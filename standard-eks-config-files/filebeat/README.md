# Procedure to deploy filebeat agent in EKS clusters

* Update kubeconfig for the respective cluster you are trying to access

```bash 
[pandark1_adm@awva-pclif03001 filebeat]$ aws eks update-kubeconfig --kubeconfig=~/.kube/eks-prd-es-5c41-cluster --name eks-prd-es-5c41-cluster --region us-east-1 --profile tfsesprod-cloud-admin-profile
Added new context arn:aws:eks:us-east-1:012511484642:cluster/eks-prd-es-5c41-cluster to /export/home/pandark1_adm/.kube/eks-prd-es-5c41-cluster
```

* Export kubeconfig to authenticate against the cluster

```bash
[pandark1_adm@awva-pclif03001 filebeat]$ export KUBECONFIG=/export/home/pandark1_adm/.kube/eks-prd-es-5c41-cluster
```

* Run kubectl commands against the cluster

```bash
[pandark1_adm@awva-pclif03001 filebeat]$ kubectl get nodes
NAME                            STATUS   ROLES    AGE     VERSION
ip-10-133-48-106.ec2.internal   Ready    <none>   6d23h   v1.14.9-eks-1f0ca9
ip-10-133-49-219.ec2.internal   Ready    <none>   6d23h   v1.14.9-eks-1f0ca9
ip-10-133-50-31.ec2.internal    Ready    <none>   6d23h   v1.14.9-eks-1f0ca9
```

* Clone the gitrepo which has the filebeat config files

```bash
[pandark1_adm@awva-pclif03001 filebeat]$ ls
01-filebeat-namespace.yaml        03-filebeat-role.yaml          05-filebeat-configmap.yaml  06-create-secret-prd.sh
02-filebeat-service-account.yaml  04-filebeat-role-binding.yaml  06-create-secret-dev.sh     07-filebeat-deamonset.yaml
```

* Apply the filebeat files in the order

```bash
[pandark1_adm@awva-pclif03001 filebeat]$ kubectl apply -f 01-filebeat-namespace.yaml
namespace/filebeat created
[pandark1_adm@awva-pclif03001 filebeat]$ kubectl apply -f 02-filebeat-service-account.yaml
serviceaccount/filebeat created
[pandark1_adm@awva-pclif03001 filebeat]$ kubectl apply -f 03-filebeat-role.yaml
clusterrole.rbac.authorization.k8s.io/filebeat created
[pandark1_adm@awva-pclif03001 filebeat]$ kubectl apply -f 04-filebeat-role-binding.yaml
clusterrolebinding.rbac.authorization.k8s.io/filebeat created
[pandark1_adm@awva-pclif03001 filebeat]$ kubectl apply -f 05-filebeat-configmap.yaml
configmap/filebeat-config created
```

* Run the create secret bash script that is specific to the cluster

```bash
[pandark1_adm@awva-pclif03001 filebeat]$ ./06-create-secret-prd.sh
secret/filebeat-es-creds created
```

* Apply filebeat daemonset

```bash
[pandark1_adm@awva-pclif03001 filebeat]$ kubectl apply -f 07-filebeat-deamonset.yaml
daemonset.apps/filebeat created
[pandark1_adm@awva-pclif03001 filebeat]$ kubectl get all -n filebeat
NAME                 READY   STATUS              RESTARTS   AGE
pod/filebeat-jgngl   0/1     ContainerCreating   0          15s
pod/filebeat-r46dl   0/1     ContainerCreating   0          15s
pod/filebeat-s7rm9   0/1     ContainerCreating   0          15s

NAME                      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/filebeat   3         3         0       3            0           <none>          16s

[pandark1_adm@awva-pclif03001 eks-deploy-tf-code]$ kubectl get all -n filebeat
NAME                 READY   STATUS    RESTARTS   AGE
pod/filebeat-9z4bz   1/1     Running   0          16h
pod/filebeat-dsltw   1/1     Running   0          16h
pod/filebeat-wljbt   1/1     Running   0          16h

NAME                      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/filebeat   3         3         3       3            3           <none>          16h
```

* To get the logs run the kubctl logs command against the required filebeat pod

```bash
kubectl logs filebeat-9z4bz -n filebeat

2020-03-19T13:53:34.363Z        INFO    log/harvester.go:297    Harvester started for file: /var/log/containers/twistlock-console-5c9c96d696-5bm6t_twistlock_twistlock-console-efc840db49a3d1c8d16bafc24dd25f17d6b1b5017f30428f44924c322179309b.log
2020-03-19T13:54:01.597Z        INFO    [monitoring]    log/log.go:145  Non-zero metrics in the last 30s        {"monitoring": {"metrics": {"beat":{"cpu":{"system":{"ticks":32340,"time":{"ms":16}},"total":{"ticks":96330,"time":{"ms":46},"value":96330},"user":{"ticks":63990,"time":{"ms":30}}},"handles":{"limit":{"hard":65536,"soft":65536},"open":14},"info":{"ephemeral_id":"e03ad2be-6d54-4a39-ab2a-48adc0c6e246","uptime":{"ms":59010022}},"memstats":{"gc_next":10802672,"memory_alloc":7448704,"memory_total":8961616920},"runtime":{"goroutines":54}},"filebeat":{"events":{"active":-2,"added":33,"done":35},"harvester":{"files":{"01971378-80fd-495b-865f-a5f6e0515062":{"last_event_published_time":"2020-03-19T13:53:32.847Z","last_event_timestamp":"2020-03-19T13:53:29.536Z","read_offset":263,"size":263},"324eb515-6d36-43e8-8f11-
```
