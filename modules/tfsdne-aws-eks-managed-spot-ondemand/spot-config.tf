resource "null_resource" "modify-spot-asg" {
  count = local.asg_count
  triggers = {
    command_arg      = local.aws_cli_command,
    asg_trigger      = local.asg_spot_policy,
    asg_name_trigger = local.asg_names_jnd,
  }
  provisioner "local-exec" {
    command = local.aws_cli_command == ""  ? "echo null"  : "aws autoscaling update-auto-scaling-group --auto-scaling-group-name ${local.asg_names[count.index]} --mixed-instances-policy '${local.aws_cli_command}' --profile ${local.profile} > asg-output.txt"
  }
  depends_on = [
    aws_autoscaling_group.workers_asg_blue,
    aws_autoscaling_group.workers_asg_green,
    aws_eks_node_group.workers_mng_blue_spot,
    aws_eks_node_group.workers_mng_green_spot,
    aws_eks_node_group.workers_mng_stateful_blue_spot,
    aws_eks_node_group.workers_mng_stateful_green_spot
  ]
}

locals {  
  asg_names = concat(
    aws_autoscaling_group.workers_asg_blue.*.name,
    aws_autoscaling_group.workers_asg_green.*.name,
    aws_eks_node_group.workers_mng_blue_spot[*].resources[0].autoscaling_groups[0].name,
    [for ng in aws_eks_node_group.workers_mng_stateful_blue_spot : ng.resources[0].autoscaling_groups[0].name ],
    aws_eks_node_group.workers_mng_green_spot[*].resources[0].autoscaling_groups[0].name,
    [for ng in aws_eks_node_group.workers_mng_stateful_green_spot : ng.resources[0].autoscaling_groups[0].name ]
  )
  asg_count = length(aws_autoscaling_group.workers_asg_blue)+length(aws_autoscaling_group.workers_asg_green)+length(aws_eks_node_group.workers_mng_blue_spot)
  asg_names_jnd   = join(" ", local.asg_names)
  profile         = split("/", var.assume-role)[1]
  asg_spot_policy = try(aws_autoscaling_group.workers_asg_blue[0].mixed_instances_policy[0].instances_distribution[0].spot_allocation_strategy , "lowest-price")
  aws_cli_command = jsonencode(
    {
      "InstancesDistribution" : {
        "OnDemandBaseCapacity" : var.on_demand_base_capacity,
        "SpotAllocationStrategy" : var.spot_allocation_strategy,
      }
    }
  )
}

data "local_file" "local_exec_output" {
  filename = "asg-output.txt"
  depends_on = [
    null_resource.modify-spot-asg
  ]
}
