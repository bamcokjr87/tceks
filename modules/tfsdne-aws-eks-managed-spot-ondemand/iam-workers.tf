resource "aws_iam_role" "node_iam_role" {
  name = format(
    var.worker_iam_name,
    var.environment_identifier,
    var.random_string,
  )

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = {
    "sourcerepo" = var.this-git-repo
    "managedby"  = "terraform"
  }

}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_iam_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_iam_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_iam_role.name
}

resource "aws_iam_role_policy_attachment" "node_tfsaws-base-ec2-policy" {
  policy_arn = "arn:aws:iam::${var.this-account-id}:policy/service/tfsaws-base-ec2-policy"
  role       = aws_iam_role.node_iam_role.name
}

resource "aws_iam_instance_profile" "node_iam_profile" {
  name = format(
    var.instance_profile_name,
    var.environment_identifier,
    var.random_string,
  )
  role = aws_iam_role.node_iam_role.name
}

