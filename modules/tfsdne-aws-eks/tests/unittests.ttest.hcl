run "setup" {
    module {
        source = "./tests/setup"   
    }
}

variables {
    # vpc_id = "vpc-09c5d8ab78006231d"
    vpc_id = "vpc-08899923641a4dd67"
    ami_owner = "602401143452"
    ebs_volume_size = 100
    ebs_volume_type = "gp3"
    delete_on_termination = true
    environment_identifier = "dev"
    region = "us-east-2"
    SnowEnvironment = "test"
    SnowAppName = "test"
    SnowChargeCode = "test"
    this-git-repo = "test"
    subnet_ids = [ "subnet-03bf6cb430d85d149", "subnet-0b80d855cf96c73af", "subnet-0803a787b5db2e5b1" ]
    # subnet_ids = ["subnet-0a6b5a733c922c9a7","subnet-08100a57e400151e0","subnet-02ecb25506bbafca8"]
    MPE = "test"
    map-migrated = "test"
    this-account-id = "123456789012"
    node_instance_type = "r5.4xlarge"
    maxpods = 3
    auto_scaling_min_size = "1"
    auto_scaling_max_size = "3"
    auto_scaling_desired_size = "2"
    # additional_eks_sgs = ["sg-04f140fd2557faaff"]
    additional_eks_sgs = ["sg-012d96c37308b3762"]
    existing_node_sg = []
    key_pair = ""
    cluster_version = "1.28"
    activate-blue-asg = ""
}

run "variables_validation" {
    command = plan

    variables {
        random_string = "${run.setup.environment_prefix.id}"
    }

    assert {
        condition = aws_eks_cluster.cluster.name == "eks-${var.environment_identifier}-${var.random_string}-cluster"
        error_message = "This is not an expected cluster name, cluster name should be in this format: eks-${var.environment_identifier}-${var.random_string}-cluster"
    }

    assert {
        condition = can(regex("^vpc-[0-9a-f]{8,17}$", var.vpc_id))
        error_message = "The VPC ID must be in the format 'vpc-xxxxxxxx' or 'vpc-xxxxxxxxxxxxxxxx', where x is a hexadecimal character."
    }

    assert {
        condition     = can(regex("^1\\.[0-9]+(\\.[0-9]+)?$", var.cluster_version))
        error_message = "The EKS cluster version must be in the format '1.Y.Z', where Y and Z are integers."
    }

    assert {
        condition = alltrue([
            for id in var.subnet_ids : can(regex("^subnet-[0-9a-f]{17}$", id))
        ])
        error_message = "Each subnet ID must be in the format 'subnet-xxxxxxxxxxxxxxxxx', where x is a hexadecimal character."
    }

    assert {
        condition = alltrue([
            for id in var.additional_eks_sgs : can(regex("^sg-[0-9a-f]{17}$", id))
        ])
        error_message = "Each security group ID must be in the format 'sg-xxxxxxxxxxxxxxxxx', where x is a hexadecimal character."
    }

    assert {
        condition     = length(var.ami_owner) == 12 && can(regex("^[0-9]{12}$", var.ami_owner))
        error_message = "ami_owner must be a valid 12-digit AWS account ID containing only numbers."
    }

    assert {
        condition     = var.ebs_volume_size >= 1 && var.ebs_volume_size <= 16384
        error_message = "ebs_volume_size must be a positive integer between 1 and 16384 GiB."
    }

    assert {
        condition = var.ebs_volume_type == "standard" || var.ebs_volume_type == "gp2" || var.ebs_volume_type == "gp3" || var.ebs_volume_type == "io1" || var.ebs_volume_type == "io2" || var.ebs_volume_type == "st1" || var.ebs_volume_type == "sc1" || var.ebs_volume_type == "pmem"
        error_message = "ebs_volume_type must be one of the following: standard, gp2, gp3, io1, io2, st1, sc1, pmem."
    }

    assert {
        condition     = var.delete_on_termination == true || var.delete_on_termination == false
        error_message = "delete_on_termination must be a boolean value (true or false)."
    }

    assert {
        condition = aws_iam_role.node_iam_role.name == "eks-${var.environment_identifier}-${var.random_string}-worker-role"
        error_message = "This is not an expected worker role name, worker role name should be in this format: eks-${var.environment_identifier}-${var.random_string}-worker-role"
    }

    assert {
        condition     = length(var.this-account-id) == 12 && can(regex("^[0-9]{12}$", var.this-account-id))
        error_message = "this-account-id must be a valid 12-digit AWS account ID consisting of only numbers."
    }

    assert {
        condition = aws_iam_instance_profile.node_iam_profile.name == "eks-${var.environment_identifier}-${var.random_string}-instance-profile"
        error_message = "This is not an expected instance profile name, instance profile name should be in this format: eks-${var.environment_identifier}-${var.random_string}-instance-profile"
    }

    assert {
        condition     = var.maxpods >= 1 && var.maxpods <= 110
        error_message = "maxpods must be a positive integer between 1 and 110."
    }

    assert {
        condition = var.node_instance_type == "t3.micro" || var.node_instance_type == "t3.small" || var.node_instance_type == "t3.medium" || var.node_instance_type == "t3.large" || var.node_instance_type == "t3.xlarge" || var.node_instance_type == "t3.2xlarge" || var.node_instance_type == "m5.large" || var.node_instance_type == "m5.xlarge" || var.node_instance_type == "m5.2xlarge" || var.node_instance_type == "m5.4xlarge" || var.node_instance_type == "m5.12xlarge" || var.node_instance_type == "m5.24xlarge" || var.node_instance_type == "c5.large" || var.node_instance_type == "c5.xlarge" || var.node_instance_type == "c5.2xlarge" || var.node_instance_type == "c5.4xlarge" || var.node_instance_type == "c5.9xlarge" || var.node_instance_type == "c5.18xlarge" || var.node_instance_type == "r5.large" || var.node_instance_type == "r5.xlarge" || var.node_instance_type == "r5.2xlarge" || var.node_instance_type == "r5.4xlarge" || var.node_instance_type == "r5.12xlarge" || var.node_instance_type == "r5.24xlarge"
        error_message = "node_instance_type must be a valid EC2 instance type."
    }

    assert {
        condition     = var.maxpods >= 1 && var.maxpods <= 110
        error_message = "maxpods must be a positive integer between 1 and 110."
    }

    assert {
        condition     = var.maxpods >= 1 && var.maxpods <= 110
        error_message = "maxpods must be a positive integer between 1 and 110."
    }

    assert {
        condition     = var.maxpods >= 1 && var.maxpods <= 110
        error_message = "maxpods must be a positive integer between 1 and 110."
    }
}

run "aws_eks_cluster_test" {
    command = plan

    variables {
        random_string = "${run.setup.environment_prefix.id}"
    }

    assert {
        condition     = aws_eks_cluster.cluster.version == "${var.cluster_version}"
        error_message = "Invalid eks cluster version"
    }

    assert {
        condition = aws_eks_cluster.cluster.tags.SnowChargeCode == "${var.SnowChargeCode}"
        error_message = "Invalid Snow Charge Code"
    }

    assert {
        condition = aws_eks_cluster.cluster.tags.SnowEnvironment == "${var.SnowEnvironment}"
        error_message = "Invalid Snow Environment"
    }

    assert {
        condition = aws_eks_cluster.cluster.tags.SnowAppName == "${var.SnowAppName}"
        error_message = "Invalid Snow App Name"
    }

    assert {
        condition = aws_eks_cluster.cluster.tags.sourcerepo == "${var.this-git-repo}"
        error_message = "Invalid Git Repo"
    }

    assert {
        condition = aws_eks_cluster.cluster.tags.map-migrated == "${var.map-migrated}"
        error_message = "Invalid Git Repo"
    }

     assert {
        condition = aws_eks_cluster.cluster.tags.map-migrated == "${var.MPE}"
        error_message = "Invalid MPE"
    }
}
