module "eks-cluster" {
  	source = "git@github.tfs.toyota.com:dne-cloud/eks-deploy-tf-modules.git//tfsdne-aws-eks-v2.0?ref=eks-v2.0-reorginized"
	region = var.region
	cluster_version = var.cluster_version
        worker-node-version = var.worker-node-version
	this-account-id = var.this-account-id
	this-git-repo = var.this-git-repo
	profile = var.profile
	assume-role = var.assume-role
	key_pair = var.key_pair
	environment_identifier = var.environment_identifier
	random_string = var.random_string
	SnowEnvironment = var.SnowEnvironment
	SnowChargeCode = var.SnowChargeCode
	SnowAppName = var.SnowAppName
	vpc_id = var.vpc_id
	subnet_ids = var.subnet_ids
	node_instance_type = var.node_instance_type
	maxpods = var.maxpods
	additional_eks_sgs = var.additional_eks_sgs
	existing_node_sg = var.existing_node_sg
	auto_scaling_min_size = var.auto_scaling_min_size
	auto_scaling_max_size = var.auto_scaling_max_size
	auto_scaling_desired_size = var.auto_scaling_desired_size
	activate-blue-asg = var.activate-blue-asg
	activate-green-asg = var.activate-green-asg	
	activate-blue-asg-spot = var.activate-blue-asg-spot
	activate-green-asg-spot = var.activate-green-asg-spot
	activate-blue-asg-spot-managed           = var.activate-blue-asg-spot-managed
    activate-green-asg-spot-managed          = var.activate-green-asg-spot-managed
    activate-blue-asg-managed-ondemand       = var.activate-blue-asg-managed-ondemand
    activate-green-asg-managed-ondemand       = var.activate-green-asg-managed-ondemand
    activate-blue-asg-spot-managed-stateful  = var.activate-blue-asg-spot-managed-stateful
    activate-green-asg-spot-managed-stateful  = var.activate-green-asg-spot-managed-stateful
    on_demand_base_capacity                  = var.on_demand_base_capacity
    on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
    spot_allocation_strategy                 = var.spot_allocation_strategy
    spot_instance_pools                      = var.spot_instance_pools
    spot_instance_overrides                  = var.spot_instance_overrides
    node-groups-self-managed = var.node-groups-self-managed
	node-groups-managed = var.node-groups-managed
	node_group_follow_latest_template_version = var.node_group_follow_latest_template_version
	app_team_namespace_without_iam_creation 								= var.app_team_namespace_without_iam_creation
	app_team_namespace_with_iam_creation				= var.app_team_namespace_with_iam_creation
	other_users									= var.other_users
	account_id									= data.aws_caller_identity.current.account_id							
	account_alias								= data.aws_iam_account_alias.current.account_alias
	app_team_users = var.app_team_users
     eks_cluster_sg                          = var.eks_cluster_sg
     pod_subnet_config                       = var.pod_subnet_config

}

# module "create-ns" {
#         source  ="./modules/namespace"	
# 		depends_on = [module.eks-cluster.value]	
# 		ns-name = var.ns-name         
# }

# module "metrics-server" {
#         source  ="./modules/metrics-server"
#                 depends_on = [module.create-ns.value]
#                 metrics_chart_name              = var.metrics_chart_name
#                 metrics_chart_release_name      = var.metrics_chart_release_name
#                 metrics_chart_repo              = var.metrics_chart_repo
#               # metrics_chart_version           = var.metrics_chart_version
#                 metrics_namespace               = var.metrics_namespace
#              #  metrics_values                  = var.metrics_values

# }

# module "dynatrace" {
#         source  ="./modules/dynatrace"
#                 depends_on = [module.create-ns.value]
#                 dynatrace_chart_name              = var.dynatrace_chart_name
#                 dynatrace_chart_release_name      = var.dynatrace_chart_release_name
#                 dynatrace_chart_repo              = var.dynatrace_chart_repo
#               # dynatrace_chart_version           = var.dynatrace_chart_version
#                 dynatrace_namespace               = var.dynatrace_namespace
#                 dynatrace_values                  = var.dynatrace_values

# }

# module "ako" {
#         source  ="./modules/ako"
#                 depends_on = [module.create-ns.value]
# 				ako_enabled                  = var.ako_enabled
#                 ako_chart_name               = var.ako_chart_name
#                 ako_chart_release_name       = var.ako_chart_release_name
#                 ako_chart_repo               = var.ako_chart_repo
#                 ako_chart_version            = var.ako_chart_version
#                 ako_namespace                = var.ako_namespace

# }
