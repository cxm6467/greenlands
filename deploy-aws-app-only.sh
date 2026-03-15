#!/bin/bash

# Quick redeploy script - only rebuilds and uploads app (no Terraform)
# Use this for iterating after initial deploy-aws.sh

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Greenfield Quick Redeploy (App Only)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Get Terraform outputs
echo -e "${BLUE}Reading Terraform outputs...${NC}"
cd terraform
CLOUDFRONT_URL=$(terraform output -raw cloudfront_url)
S3_BUCKET=$(terraform output -raw s3_bucket_name)
CF_DIST_ID=$(terraform output -raw cloudfront_distribution_id)
AWS_REGION=$(terraform output -raw cloudfront_url | grep -oP 'https://\K[^.]+' || echo "us-east-1")
cd ..

echo -e "${GREEN}✓ CloudFront: $CLOUDFRONT_URL${NC}"
echo -e "${GREEN}✓ S3 Bucket: $S3_BUCKET${NC}"
echo ""

# Build
echo -e "${BLUE}Building Flutter web app...${NC}"
~/flutter/bin/flutter build web \
  --release \
  --dart-define="AI_PROXY_URL=${CLOUDFRONT_URL}/api/claude" > /dev/null 2>&1
echo -e "${GREEN}✓ Web app built${NC}"
echo ""

# Upload
echo -e "${BLUE}Uploading to S3...${NC}"
aws s3 sync build/web "s3://${S3_BUCKET}" \
  --delete \
  --cache-control "max-age=31536000" \
  --exclude "index.html" > /dev/null 2>&1

aws s3 cp build/web/index.html "s3://${S3_BUCKET}/" \
  --cache-control "max-age=0, no-cache" \
  --content-type "text/html" > /dev/null 2>&1
echo -e "${GREEN}✓ Assets uploaded${NC}"
echo ""

# Invalidate cache
echo -e "${BLUE}Invalidating CloudFront cache...${NC}"
aws cloudfront create-invalidation \
  --distribution-id "$CF_DIST_ID" \
  --paths "/*" > /dev/null 2>&1
echo -e "${GREEN}✓ Cache invalidated${NC}"
echo ""

echo -e "${GREEN}✓ Done! App updated at:${NC}"
echo -e "${GREEN}$CLOUDFRONT_URL${NC}"
