provider "aws" {
  region = var.region
  profile = var.profile
  assume_role {
    role_arn     = "arn:aws:iam::${var.this-account-id}:role/${var.assume-role}"
    session_name = "terraform"
  }
}