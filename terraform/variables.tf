variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name (used for resource naming)"
  type        = string
  default     = "greenfield"
}

variable "bedrock_api_key" {
  description = "AWS Bedrock API key for authentication"
  type        = string
  sensitive   = true
  # No default - must be provided via -var or terraform.tfvars
}

variable "environment" {
  description = "Environment name (prod, staging, etc)"
  type        = string
  default     = "prod"
}

variable "bedrock_model" {
  description = "Bedrock model ID to use"
  type        = string
  default     = "anthropic.claude-3-haiku-20240307-v1:0"
}

variable "domain_name" {
  description = "Custom domain name for CloudFront (optional, e.g., greenfield.chrismarasco.io)"
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID for the parent domain (e.g., chrismarasco.io)"
  type        = string
  default     = ""
}
