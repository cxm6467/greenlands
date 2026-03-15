# Greenfield AWS Deployment Guide

Complete infrastructure-as-code setup for deploying Greenfield to AWS using Terraform.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      CloudFront CDN                         │
│                 (caching + HTTPS + DDoS)                    │
│                   greenfield.chrismarasco.io                │
└────────────────┬──────────────────┬────────────────────────┘
                 │                  │
        ┌────────▼─────┐    ┌──────▼──────┐
        │  S3 Bucket   │    │ API Gateway │
        │  (Static Web)│    │  (HTTP API) │
        └──────────────┘    └──────┬──────┘
                                   │
                            ┌──────▼──────┐
                            │   Lambda    │
                            │   (Proxy)   │
                            └──────┬──────┘
                                   │
                ┌──────────────────┼──────────────────┐
                │                  │                  │
        ┌──────▼───────┐  ┌───────▼──────┐  ┌──────▼────────┐
        │   Bedrock    │  │ SSM Secrets  │  │  CloudWatch   │
        │   (Claude)   │  │  (API Keys)  │  │  (Logging)    │
        └──────────────┘  └──────────────┘  └───────────────┘
```

## Prerequisites

### Required
- AWS Account with permissions for: Lambda, API Gateway, S3, CloudFront, IAM, SSM, ACM, Route 53
- AWS CLI configured (`aws configure`)
- Terraform >= 1.0 (`terraform --version`)
- Bedrock model enabled: `anthropic.claude-3-haiku-20240307-v1:0` (see AWS Console → Bedrock → Model Access)

### Optional (for custom domain)
- Route 53 hosted zone for your domain (e.g., chrismarasco.io)
- Route 53 hosted zone ID

## Quick Start (5 min)

### 1. Get Your Bedrock API Key
1. Go to [AWS Console - Bedrock](https://console.aws.amazon.com/bedrock/)
2. Click **API keys** in the left sidebar
3. Click **Create API key** (or copy existing)
4. Copy the key (starts with `ABSKY`)

### 2. Deploy Infrastructure

```bash
./deploy-aws.sh
```

The script will:
1. Prompt for Bedrock API key
2. Ask for AWS region (default: `us-east-1`)
3. Optionally ask for custom domain (e.g., `greenfield.chrismarasco.io`)
4. Build Lambda function
5. Run `terraform apply`
6. Build Flutter web app
7. Upload to S3
8. Invalidate CloudFront cache

**Output example:**
```
✓ CloudFront: https://d111111abcdef8.cloudfront.net
✓ S3 Bucket: greenfield-web-prod-123456789
✓ API Gateway: https://abc123def456.execute-api.us-east-1.amazonaws.com
✓ Lambda Function: greenfield-proxy-prod
```

## Deployment Options

### Option A: AWS CloudFront URL Only (fastest)
```bash
./deploy-aws.sh
# Skip custom domain prompt
# App will be live at: https://d111111abcdef8.cloudfront.net
```

### Option B: Custom Domain (e.g., greenfield.chrismarasco.io)
```bash
./deploy-aws.sh
# When prompted:
#   Domain: greenfield.chrismarasco.io
#   Route 53 Zone ID: Z1234567890ABC
# App will be live at: https://greenfield.chrismarasco.io
```

Get your Route 53 Zone ID:
```bash
aws route53 list-hosted-zones-by-name --dns-name chrismarasco.io
```

Look for `"Id": "/hostedzone/Z1234567890ABC"` → Zone ID is `Z1234567890ABC`

## File Structure

```
terraform/
├── main.tf             # S3, CloudFront, Lambda, API Gateway, SSM, IAM, ACM, Route 53
├── variables.tf        # bedrock_api_key, aws_region, domain_name, route53_zone_id
├── outputs.tf          # URLs and resource IDs
└── lambda/
    ├── index.js        # Lambda handler (proxy to Bedrock)
    └── package.json    # Dependencies

deploy-aws.sh           # Full infrastructure + app deployment
deploy-aws-app-only.sh  # Quick app redeploy (no Terraform)
AWS_DEPLOYMENT.md       # This file
```

## Terraform Variables

Can be set via command line or `terraform.tfvars`:

```hcl
bedrock_api_key = "ABSKY..."  # Required: Your Bedrock API key
aws_region = "us-east-1"      # Optional: AWS region
app_name = "greenfield"        # Optional: Application name
environment = "prod"           # Optional: Environment name
domain_name = ""               # Optional: Custom domain
route53_zone_id = ""           # Optional: Route 53 zone ID
bedrock_model = "..."          # Optional: Bedrock model
```

## Redeploying

### Full Infrastructure + App Redeploy
```bash
./deploy-aws.sh
```

### Quick App Redeploy Only (no infrastructure changes)
Use after initial deployment for faster iterations:
```bash
./deploy-aws-app-only.sh
```

This rebuilds Flutter web, uploads to S3, and invalidates CloudFront cache in ~30 seconds.

## Costs

| Service | Estimate |
|---------|----------|
| Lambda | ~$0 (1M free requests/month) |
| API Gateway HTTP API | ~$1/million requests |
| S3 | ~$0.023/GB storage |
| CloudFront | ~$0.0085/GB transfer |
| Bedrock Haiku | ~$0.001/quest |
| **Total at low traffic** | **~$0-2/month** |

## Troubleshooting

### "Bedrock API key invalid"
- Verify key format (should start with `ABSKY`)
- Check key is still active in AWS Console
- Regenerate if needed

### "CloudFront takes 15 minutes to deploy"
- This is normal for first CloudFront distribution
- Subsequent deployments are faster
- Use `./deploy-aws-app-only.sh` for quicker iterations

### "Custom domain returns 403"
- Wait 5-10 minutes for CloudFront to fully deploy
- Check Route 53 record is created: `aws route53 list-resource-record-sets --hosted-zone-id Z1234567890ABC`
- Verify ACM certificate is validated (check AWS Console → ACM)

### "Lambda returns 500 error"
Check Lambda logs:
```bash
aws logs tail /aws/lambda/greenfield-proxy-prod --follow
```

### "S3 upload fails with 'Access Denied'"
Verify AWS credentials:
```bash
aws sts get-caller-identity
```

## Manual Terraform Commands

### View current infrastructure
```bash
cd terraform
terraform state list
terraform state show 'aws_lambda_function.proxy'
```

### Update infrastructure without redeploying app
```bash
cd terraform
terraform apply -var="bedrock_api_key=ABSKY..." -var="aws_region=us-east-1"
```

### Destroy all infrastructure (⚠️ WARNING)
```bash
cd terraform
terraform destroy -var="bedrock_api_key=ABSKY..."
```

## Security Notes

- Bedrock API key stored securely in **AWS SSM Parameter Store** (encrypted)
- Lambda has IAM role restricted to: Bedrock InvokeModel + SSM GetParameter
- S3 bucket is **private** (only accessible via CloudFront)
- CloudFront enforces HTTPS + has DDoS protection
- No secrets in code, environment variables, or Git

## Monitoring

### View Lambda Logs
```bash
aws logs tail /aws/lambda/greenfield-proxy-prod --follow
```

### View CloudFront Cache Statistics
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/CloudFront \
  --metric-name CacheHitRate \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Average
```

### Check API Gateway Metrics
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApiGateway \
  --metric-name Count \
  --dimensions Name=ApiName,Value=greenfield-api-prod \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Sum
```

## What's New vs Firebase

| Aspect | Firebase | AWS |
|--------|----------|-----|
| **Hosting** | Firebase Hosting | S3 + CloudFront |
| **Proxy** | Cloud Functions | Lambda + API Gateway |
| **Secrets** | Runtime Config | SSM Parameter Store |
| **DNS** | Firebase default | Route 53 + custom domain |
| **IaC** | firebase.json | Terraform |
| **Cost** | Free tier limited | Pay-per-use |
| **Domain** | *.web.app | Your domain |

## Model Options

Default: `anthropic.claude-3-haiku-20240307-v1:0` (cheapest, ~$0.001/quest)

Other available models:
- `anthropic.claude-3-5-haiku-20241022-v1:0` - Newer haiku, slightly better
- `anthropic.claude-3-sonnet-20240229-v1:0` - More capable (~$0.002/quest)
- `anthropic.claude-3-opus-20240229-v1:0` - Most capable (~$0.01/quest)

To change model, edit `terraform/variables.tf`:
```hcl
variable "bedrock_model" {
  default = "anthropic.claude-3-opus-20240229-v1:0"  # Change this
}
```

Then redeploy:
```bash
./deploy-aws.sh
```

## Next Steps

- **Rebrand to Greenfield**: Update app name in `lib/main.dart` and Flutter pubspec
- **Add pixel art grass**: Add to `lib/presentation/pages/home_page.dart`
- **Custom domain**: Update `DOMAIN_NAME` variable
- **Multi-region**: Replicate `terraform/` for different regions

---

**Questions?** Check AWS docs:
- [Lambda](https://docs.aws.amazon.com/lambda/)
- [API Gateway](https://docs.aws.amazon.com/apigateway/)
- [CloudFront](https://docs.aws.amazon.com/cloudfront/)
- [Bedrock](https://docs.aws.amazon.com/bedrock/)
