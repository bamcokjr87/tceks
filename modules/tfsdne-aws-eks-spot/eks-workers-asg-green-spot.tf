locals {
  worker-node-userdata-green-spot = <<USERDATA
#!/bin/bash
set -o xtrace
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.cluster.certificate_authority[0].data}' '${aws_eks_cluster.cluster.name}' --use-max-pods false --kubelet-extra-args "--node-labels=k8s.amazonaws.com/eniConfig=$AZ --max-pods=${var.maxpods} --image-pull-progress-deadline=30m"
curl -o eks-node-postscript.sh https://s3.amazonaws.com/tfs-prod-repo/tfsrepo/linux/scripts/eks-node-postscript.sh && chmod +x eks-node-postscript.sh && bash eks-node-postscript.sh >> /root/eks-node-postscript.log 
USERDATA

}

resource "aws_launch_template" "launch_template-green"{
    
    name ="${aws_eks_cluster.cluster.name}-launch_template-green"    
    key_name = var.key_pair
    iam_instance_profile {
      name   =aws_iam_instance_profile.node_iam_profile.name
    }    
    block_device_mappings {      
        device_name = "/dev/xvda"
        ebs {            
            volume_size = var.ebs_volume_size
            volume_type = var.ebs_volume_type
            delete_on_termination = var.delete_on_termination
            encrypted		  = true
        }
    }
    instance_type = var.node_instance_type
    image_id = data.aws_ami.eks_node_ami.id
    vpc_security_group_ids = flatten([ aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id, var.existing_node_sg[*] ])
    user_data = base64encode(local.worker-node-userdata-green-spot)

} 

resource "aws_autoscaling_group" "workers_asg_green"{
  count = var.activate-green-asg-spot == "true" ? 1 : 0
  desired_capacity     = var.auto_scaling_desired_size
  max_size             = var.auto_scaling_max_size
  min_size             = var.auto_scaling_min_size
  name = format(
    var.auto_scale_group_name,
    var.environment_identifier,
    var.random_string,
    "green-spot",
  )
  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupInServiceInstances", "GroupDesiredCapacity"]
  vpc_zone_identifier = var.subnet_ids
  mixed_instances_policy {
      instances_distribution {
          on_demand_base_capacity = var.on_demand_base_capacity
          on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
          spot_allocation_strategy = var.spot_allocation_strategy
          spot_instance_pools  = var.spot_instance_pools 
          spot_max_price  = var.spot_max_price 
      }
      launch_template{
          launch_template_specification{
              launch_template_id = aws_launch_template.launch_template-green.id
          }
      }
  }
  tag {
    key                 = "Name"
    value               = "${aws_eks_cluster.cluster.name}-node"
    propagate_at_launch = true
  }
  tag {
    key                 = "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}"
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = "SnowChargeCode"
    value               = var.SnowChargeCode
    propagate_at_launch = true
  }

  tag {
    key			= "SnowEnvironment"
    value		= var.SnowEnvironment  
    propagate_at_launch = true
  }
  tag {
    key                 = "SnowAppName"
    value               = var.SnowAppName
    propagate_at_launch = true
   }
   tag {
     key                 = "managedby"
     value               = "terraform"
     propagate_at_launch = true
   }
   tag {
     key                 = "sourcerepo"
     value               = var.this-git-repo
     propagate_at_launch = true
   }
 }