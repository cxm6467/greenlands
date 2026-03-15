# GitHub Actions Setup Guide

This document explains how to configure GitHub Actions for CI/CD deployment to AWS.

## Overview

The CI/CD pipeline includes:
1. **Test & Lint** (PR + Push): Format code, analyze, run health check tests
2. **Build** (PR + Push): Compile Flutter web app with Dart optimization
3. **Deploy** (Push to main only): Sync to S3, invalidate CloudFront cache

## Required GitHub Secrets

Configure these secrets in `Settings → Secrets and variables → Actions`:

### AWS Credentials

| Secret Name | Value | Notes |
|---|---|---|
| `AWS_ACCESS_KEY_ID` | Your AWS access key | Use IAM user with S3 + CloudFront permissions |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | **Sensitive** - store securely |
| `AWS_S3_BUCKET` | `greenfield-web-prod-276362266002` | S3 bucket name |
| `AWS_CLOUDFRONT_DISTRIBUTION_ID` | `EWU6INWV925A` | CloudFront distribution ID |

## IAM Policy for GitHub Actions

Create an IAM user with the minimum required permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::greenfield-web-prod-276362266002",
        "arn:aws:s3:::greenfield-web-prod-276362266002/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateInvalidation",
        "cloudfront:GetInvalidation",
        "cloudfront:ListInvalidations"
      ],
      "Resource": "arn:aws:cloudfront::276362266002:distribution/EWU6INWV925A"
    }
  ]
}
```

## Setting Up Secrets

### Via GitHub CLI
```bash
gh secret set AWS_ACCESS_KEY_ID --body "YOUR_KEY"
gh secret set AWS_SECRET_ACCESS_KEY --body "YOUR_SECRET"
gh secret set AWS_S3_BUCKET --body "greenfield-web-prod-276362266002"
gh secret set AWS_CLOUDFRONT_DISTRIBUTION_ID --body "EWU6INWV925A"
```

### Via Web UI
1. Go to repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add each secret from the table above

## Workflow Execution

### Triggers
- **On every PR to main**: Runs test, lint, build (no deploy)
- **On push to main**: Runs test, lint, build, deploy
- **Manual dispatch**: Not currently enabled (can be added if needed)

### Monitoring

View workflow runs at: `Actions → Workflows → CI/CD Pipeline`

Each run shows:
- ✅ Test & Lint step (always runs)
- ✅ Build step (always runs after test)
- ✅ Deploy step (only on main branch push)

## Deployment URLs

After successful deployment to main, app is available at:
- **Custom domain**: https://greenfield.chrismarasco.io
- **CloudFront**: https://d3814txe1aqheb.cloudfront.net

CloudFront cache is automatically invalidated on each deployment, so changes are live within seconds.

## Troubleshooting

### Build fails with analyzer errors
- Commit must pass `flutter analyze` locally first
- Run locally: `flutter analyze` before pushing

### Deploy fails with AWS credentials error
- Verify secrets are correctly set (typo-free)
- Ensure IAM user has required permissions (see policy above)
- Check AWS account is correct (276362266002)

### S3 sync doesn't delete old files
- Current config uses `--delete` flag
- Only deletes files that aren't in local build/web directory
- For full cleanup, manually empty S3 before deployment

### CloudFront invalidation slow
- Invalidations typically complete within 30-60 seconds
- You can check status: `aws cloudfront get-invalidation --id <ID> --distribution-id <DIST_ID>`

## Local Testing

To test the build locally with the same dart-define flags:

```bash
flutter build web --release --dart-define="AI_PROXY_URL=https://greenfield.chrismarasco.io/api/claude"
```

## Security Notes

- Never commit AWS credentials to the repository
- Always use IAM users with minimal required permissions (least privilege)
- Rotate credentials periodically
- Use environment variables, not hardcoded values, in workflow files
- Secrets are never logged or displayed in workflow output

## Future Enhancements

Possible additions to the workflow:
1. Performance metrics collection after deployment
2. Slack/Discord notifications on deployment success/failure
3. Manual approval required before deploy to production
4. E2E testing with Selenium/Playwright before deploy
5. Automated database migrations if backend is added
6. Automated version bump and release tags
