#!/bin/bash

# Production deployment script for AWS
# Deploys Terraform infrastructure and Flutter web app to S3/CloudFront

set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}→ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_header "Greenfield AWS Deployment"

# Check dependencies
print_step "Checking dependencies..."

if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed"
    exit 1
fi
print_success "Terraform found"

if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed"
    exit 1
fi
print_success "AWS CLI found"

if ! command -v ~/flutter/bin/flutter &> /dev/null; then
    print_error "Flutter not found at ~/flutter/bin/flutter"
    exit 1
fi
print_success "Flutter found"

echo ""

# Verify AWS credentials
print_step "Verifying AWS credentials..."
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    print_error "AWS credentials not configured"
    echo "Run: aws configure"
    exit 1
fi
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
print_success "AWS account: $ACCOUNT_ID"

echo ""

# Get Bedrock API key
print_step "Getting Bedrock API key..."
read -sp "Enter your Bedrock API key (ABSKY...): " BEDROCK_API_KEY
echo ""

if [ -z "$BEDROCK_API_KEY" ]; then
    print_error "Bedrock API key is required"
    exit 1
fi

echo ""

# Get optional AWS region
read -p "Enter AWS region (default: us-east-1): " AWS_REGION
AWS_REGION=${AWS_REGION:-us-east-1}
print_success "Using region: $AWS_REGION"

echo ""

# Get optional custom domain
read -p "Enter custom domain (optional, e.g., greenfield.chrismarasco.io): " DOMAIN_NAME
if [ -n "$DOMAIN_NAME" ]; then
    read -p "Enter Route 53 hosted zone ID for the parent domain: " ROUTE53_ZONE_ID
    if [ -z "$ROUTE53_ZONE_ID" ]; then
        print_warning "No hosted zone ID provided - will deploy without custom domain"
        DOMAIN_NAME=""
    fi
fi

echo ""

# Step 1: Install Lambda dependencies
print_header "Step 1: Preparing Lambda function"

print_step "Installing Lambda dependencies..."
cd terraform/lambda
npm install > /dev/null 2>&1
print_success "Dependencies installed"

cd ../..

echo ""

# Step 2: Terraform init and plan
print_header "Step 2: Initializing Terraform"

print_step "Initializing Terraform..."
cd terraform
terraform init -upgrade > /dev/null 2>&1
print_success "Terraform initialized"

echo ""

# Step 3: Terraform plan
print_step "Planning Terraform deployment..."
TERRAFORM_VARS="-var=\"bedrock_api_key=$BEDROCK_API_KEY\" -var=\"aws_region=$AWS_REGION\""
if [ -n "$DOMAIN_NAME" ]; then
    TERRAFORM_VARS="$TERRAFORM_VARS -var=\"domain_name=$DOMAIN_NAME\" -var=\"route53_zone_id=$ROUTE53_ZONE_ID\""
fi

terraform plan $TERRAFORM_VARS -out=tfplan > /dev/null 2>&1
print_success "Terraform plan created"

echo ""

# Step 4: Confirm deployment
echo "Ready to deploy to AWS:"
echo "  - Lambda proxy function"
echo "  - API Gateway (HTTP API)"
echo "  - S3 bucket (static assets)"
echo "  - CloudFront distribution (CDN)"
echo "  - SSM Parameter Store (secrets)"
echo ""
read -p "Continue with deployment? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Deployment cancelled"
    exit 1
fi

echo ""

# Step 5: Apply Terraform
print_header "Step 3: Applying Terraform configuration"

print_step "Applying Terraform..."
terraform apply -auto-approve tfplan > /dev/null 2>&1
print_success "Infrastructure deployed to AWS"

# Get outputs
CLOUDFRONT_URL=$(terraform output -raw cloudfront_url)
S3_BUCKET=$(terraform output -raw s3_bucket_name)
CF_DIST_ID=$(terraform output -raw cloudfront_distribution_id)
API_URL=$(terraform output -raw api_gateway_url)

echo ""
print_success "CloudFront URL: $CLOUDFRONT_URL"
print_success "S3 Bucket: $S3_BUCKET"
print_success "API Gateway: $API_URL"

cd ../..

echo ""

# Step 6: Build Flutter web
print_header "Step 4: Building Flutter web app"

print_step "Building Flutter for production..."
~/flutter/bin/flutter build web \
  --release \
  --dart-define="AI_PROXY_URL=${CLOUDFRONT_URL}/api/claude" > /dev/null 2>&1
print_success "Web app built"

echo ""

# Step 7: Upload to S3
print_header "Step 5: Uploading to S3"

print_step "Syncing assets to S3..."
aws s3 sync build/web "s3://${S3_BUCKET}" \
  --region "$AWS_REGION" \
  --delete \
  --cache-control "max-age=31536000" \
  --exclude "index.html" > /dev/null 2>&1

# Upload index.html with no cache
aws s3 cp build/web/index.html "s3://${S3_BUCKET}/" \
  --region "$AWS_REGION" \
  --cache-control "max-age=0, no-cache" \
  --content-type "text/html" > /dev/null 2>&1

print_success "Assets uploaded to S3"

echo ""

# Step 8: Invalidate CloudFront cache
print_header "Step 6: Invalidating CloudFront cache"

print_step "Invalidating CloudFront distribution..."
aws cloudfront create-invalidation \
  --distribution-id "$CF_DIST_ID" \
  --paths "/*" > /dev/null 2>&1
print_success "CloudFront cache invalidated"

echo ""

# Success summary
print_header "Deployment Complete!"

echo "Your app is now live at:"
echo -e "${GREEN}$CLOUDFRONT_URL${NC}"
echo ""
echo "Infrastructure:"
echo "  CloudFront: $CLOUDFRONT_URL"
echo "  S3 Bucket: $S3_BUCKET"
echo "  API Gateway: $API_URL"
echo "  AWS Region: $AWS_REGION"
echo ""
echo "To view Lambda logs:"
echo "  aws logs tail /aws/lambda/greenfield-proxy-prod --follow"
echo ""
echo "To redeploy just the app (without infrastructure):"
echo "  ./deploy-aws-app-only.sh"
echo ""
