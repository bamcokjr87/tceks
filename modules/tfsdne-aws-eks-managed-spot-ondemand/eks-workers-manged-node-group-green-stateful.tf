locals {
  worker-managed-node-userdata-stateful_green-spot = <<USERDATA
#!/bin/bash
set -o xtrace
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.cluster.certificate_authority[0].data}' '${aws_eks_cluster.cluster.name}' --use-max-pods false --kubelet-extra-args "--node-labels=k8s.amazonaws.com/eniConfig=$AZ --max-pods=${var.maxpods} --image-pull-progress-deadline=30m"
curl -o eks-node-postscript.sh https://s3.amazonaws.com/tfs-prod-repo/tfsrepo/linux/scripts/eks-node-postscript.sh && chmod +x eks-node-postscript.sh && bash eks-node-postscript.sh >> /root/eks-node-postscript.log 
USERDATA

}

resource "aws_launch_template" "managed_launch_template-stateful_green" {  
  name     = "${aws_eks_cluster.cluster.name}-managed_launch_template-stateful_green"
  key_name = var.key_pair
  # iam_instance_profile {
  #   name   =aws_iam_instance_profile.node_iam_profile.name
  # }    
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.ebs_volume_size
      volume_type           = var.ebs_volume_type
      delete_on_termination = var.delete_on_termination
      encrypted             = true
    }
  }
  update_default_version = true
 # instance_type          = var.node_instance_type
  image_id               = data.aws_ami.eks_node_ami.id
  vpc_security_group_ids = flatten([aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id, var.existing_node_sg[*]])
  user_data              = base64encode(local.worker-managed-node-userdata-stateful_green-spot)
}

resource "aws_eks_node_group" "workers_mng_stateful_green_spot" {
  for_each        = var.activate-green-asg-spot-managed-stateful == "true" ? {for i, subnet in var.subnet_ids: "AZ${i}"=> subnet} : {}
  node_group_name = "${aws_eks_cluster.cluster.name}-managed-node-stateful_green-${each.key}" 
  cluster_name    = aws_eks_cluster.cluster.name
  node_role_arn   = aws_iam_role.node_iam_role.arn
  subnet_ids      = [each.value]
  capacity_type   = "SPOT"
  instance_types  = [for override_key, override in var.spot_instance_overrides : override.instance_type ]

  scaling_config {
    desired_size = floor(var.auto_scaling_desired_size/length(var.subnet_ids))
    max_size     = ceil(var.auto_scaling_max_size/length(var.subnet_ids))
    min_size     = ceil(var.auto_scaling_min_size/length(var.subnet_ids))
  }

  launch_template {
    id      = aws_launch_template.managed_launch_template-stateful_green.id
    version = aws_launch_template.managed_launch_template-stateful_green.default_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
  #    tags = {
  #     key                 = "Name"
  #     value               = "${aws_eks_cluster.cluster.name}-node"
  #     propagate_at_launch = true
  #   }
  #   tag {
  #     key                 = "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}"
  #     value               = "owned"
  #     propagate_at_launch = true
  #   }
  #   tag {
  #     key                 = "SnowChargeCode"
  #     value               = var.SnowChargeCode
  #     propagate_at_launch = true
  #   }

  #   tag {
  #     key			= "SnowEnvironment"
  #     value		= var.SnowEnvironment  
  #     propagate_at_launch = true
  #   }
  #   tag {
  #     key                 = "SnowAppName"
  #     value               = var.SnowAppName
  #     propagate_at_launch = true
  #    }
  #    tag {
  #      key                 = "managedby"
  #      value               = "terraform"
  #      propagate_at_launch = true
  #    }
  #    tag {
  #      key                 = "sourcerepo"
  #      value               = var.this-git-repo
  #      propagate_at_launch = true
  #    }

}