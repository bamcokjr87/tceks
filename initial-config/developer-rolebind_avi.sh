#!/bin/bash
read -p "Enter the name of the namespace: " namespace 
### Apply new RBAC role to the namespace $namespace ###

read -p "Enter the name of the user to be added to the clusterrole: " user
kubectl create rolebinding $namespace-rolebind --namespace=$namespace --clusterrole=tfseksdeveloperscluster-role --user=$user --save-config=true

### Review the rolebinding ####

kubectl describe rolebinding $namespace-rolebind -n $namespace
