# resource "aws_eks_addon" "eks_addon_driver" {
#   cluster_name = "eks-lab-dne01-vuzp-cluster"
#   addon_name   = "aws-ebs-csi-driver"
# }


# resource "aws_iam_policy" "eks_addon_policy" {
#   name        = "eks_addon_policy"
#   description = "eks_addon_policy for KMS"

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Action": [
#           "kms:CreateGrant",
#           "kms:ListGrants",
#           "kms:RevokeGrant"
#         ],
#         "Resource": ["arn:aws:kms:us-east-1:307377368910:key/07c3adce-bdc9-439a-ad7e-81b06496a56c"],
#         "Condition": {
#           "Bool": {
#             "kms:GrantIsForAWSResource": "true"
#           }
#         }
#       },
#       {
#         "Effect": "Allow",
#         "Action": [
#           "kms:Encrypt",
#           "kms:Decrypt",
#           "kms:ReEncrypt*",
#           "kms:GenerateDataKey*",
#           "kms:DescribeKey"
#         ],
#         "Resource": ["arn:aws:kms:us-east-1:307377368910:key/07c3adce-bdc9-439a-ad7e-81b06496a56c"]
#       }
#     ]
#   })
# }

# resource "aws_iam_role" "eks_addon_iamrole" {
#   name               = "aws-ebs-csi-driver-role"
#   assume_role_policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Principal": {
#           "Service": "ec2.amazonaws.com"
#         },
#         "Action": "sts:AssumeRole"
#       }
#     ]
#   }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "eks_addon_iam_kms_policy_attachement" {
#   policy_arn = aws_iam_policy.eks_addon_policy.arn
#   role       = aws_iam_role.eks_addon_iamrole.name
# }

# resource "aws_iam_role_policy_attachment" "eks_addon_iam_policy_attachement" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.eks_addon_iamrole.name
# }