output "state_bucket" {
  description = "The S3 bucket to store the remote state file."
  value       = module.remote_state.state_bucket.bucket
}

output "dynamodb_table" {
  description = "The DynamoDB table to manage lock states."
  value       = module.remote_state.dynamodb_table.name
}