# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
# data "aws_region" "current" {}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  worker-node-userdata-green = <<USERDATA
#!/bin/bash
set -o xtrace
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.cluster.certificate_authority[0].data}' '${aws_eks_cluster.cluster.name}' --use-max-pods false --kubelet-extra-args "--node-labels=k8s.amazonaws.com/eniConfig=$AZ --max-pods=${var.maxpods} --image-pull-progress-deadline=30m"
curl -o eks-node-postscript.sh https://s3.amazonaws.com/tfs-prod-repo/tfsrepo/linux/scripts/eks-node-postscript.sh && chmod +x eks-node-postscript.sh && bash eks-node-postscript.sh >> /root/eks-node-postscript.log 
USERDATA

}

resource "aws_launch_configuration" "launch_configuration-green" {
  
  iam_instance_profile = aws_iam_instance_profile.node_iam_profile.name
  image_id             = data.aws_ami.eks_node_ami.id
  instance_type        = var.node_instance_type
  name_prefix = format(
    var.launch_configuration_name,
    var.environment_identifier,
    var.random_string,
    "green",
  )

  #security_groups  = [aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id, var.existing_node_sg != "" ? var.existing_node_sg : null]
  security_groups  = flatten([ aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id, var.existing_node_sg[*] ])
  user_data_base64 = base64encode(local.worker-node-userdata-green)
  key_name         = var.key_pair

  root_block_device {
    #device_name = "/dev/xvda"
    volume_size           = var.ebs_volume_size
    volume_type           = var.ebs_volume_type
    delete_on_termination = var.delete_on_termination
    encrypted		  = true
  }

  # ebs_block_device {
  # }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "auto_scaling_group-green" {

  count = var.activate-green-asg == "true" ? 1 : 0

  desired_capacity     = var.auto_scaling_desired_size
  launch_configuration = aws_launch_configuration.launch_configuration-green.id
  max_size             = var.auto_scaling_max_size
  min_size             = var.auto_scaling_min_size
  name = format(
    var.auto_scale_group_name,
    var.environment_identifier,
    var.random_string,
    "green",
  )
  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupInServiceInstances", "GroupDesiredCapacity"]
  vpc_zone_identifier = var.subnet_ids

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

