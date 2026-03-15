# GitHub Actions Secrets Setup Checklist

## Quick Setup

Before merging the CI/CD workflow to main, configure these 4 secrets:

### ✅ Step 1: Get AWS Credentials

1. Go to [AWS IAM Console](https://console.aws.amazon.com/iam)
2. Create a new IAM user (e.g., `github-actions-greenfield`)
3. Attach inline policy (see `GITHUB_ACTIONS_SETUP.md`)
4. Create access key for that user
5. Copy the Access Key ID and Secret Key

### ✅ Step 2: Add Secrets to GitHub

Go to: `https://github.com/YOUR_ORG/greenfield/settings/secrets/actions`

Add these 4 secrets:

| Name | Value |
|------|-------|
| `AWS_ACCESS_KEY_ID` | (from IAM user access key) |
| `AWS_SECRET_ACCESS_KEY` | (from IAM user secret key) |
| `AWS_S3_BUCKET` | `greenfield-web-prod-276362266002` |
| `AWS_CLOUDFRONT_DISTRIBUTION_ID` | `EWU6INWV925A` |

### ✅ Step 3: Verify Setup

After adding secrets:
1. Create a test branch from main
2. Push a small change (e.g., update README)
3. Create a PR to main
4. Check `Actions` tab to see test/lint/build run
5. Merge PR to main to trigger full deployment
6. Verify app updates at https://greenfield.chrismarasco.io

## AWS Account Info

- **Account ID**: 276362266002
- **Region**: us-east-1 (primary), us-east-1 for ACM
- **S3 Bucket**: greenfield-web-prod-276362266002
- **CloudFront Distribution**: EWU6INWV925A

## Need Help?

See `GITHUB_ACTIONS_SETUP.md` for:
- Detailed IAM policy JSON
- Troubleshooting guide
- Security best practices
- GitHub CLI commands to set secrets

## Status Check

After secrets are added, you should see:
- ✅ PR workflow runs (test, lint, build)
- ✅ Push to main triggers deploy (S3 sync + CloudFront invalidation)
- ✅ App updates at https://greenfield.chrismarasco.io within seconds
