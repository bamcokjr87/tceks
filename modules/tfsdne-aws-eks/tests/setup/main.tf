resource "random_string" "environment_prefix" {
  length = 4
  special = false
}

output "environment_prefix" {
  value = random_string.environment_prefix
}
