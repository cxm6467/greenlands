output "cloudfront_url" {
  description = "CloudFront distribution URL - the main app URL"
  value       = "https://${aws_cloudfront_distribution.web.domain_name}"
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name"
  value       = aws_cloudfront_distribution.web.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (for cache invalidation)"
  value       = aws_cloudfront_distribution.web.id
}

output "api_gateway_url" {
  description = "API Gateway URL (direct access, for debugging)"
  value       = aws_apigatewayv2_api.proxy.api_endpoint
}

output "s3_bucket_name" {
  description = "S3 bucket name for web assets"
  value       = aws_s3_bucket.web.id
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.proxy.function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.proxy.arn
}

output "ssm_parameter_name" {
  description = "SSM Parameter Store name for Bedrock API key"
  value       = aws_ssm_parameter.bedrock_api_key.name
}

output "custom_domain_url" {
  description = "Custom domain URL (if configured)"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "Not configured"
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN (for custom domain)"
  value       = var.domain_name != "" ? aws_acm_certificate.domain[0].arn : null
}
