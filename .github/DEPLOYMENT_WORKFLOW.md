# Greenfield Deployment & CI/CD Workflow

## Architecture Overview

```
                        ┌─────────────────────────────────────────┐
                        │         GitHub Repository               │
                        │  (fix/disable-claude-api-on-web branch) │
                        └────────────────┬────────────────────────┘
                                         │
                                         ▼
                    ┌────────────────────────────────────────┐
                    │    GitHub Actions CI/CD Pipeline       │
                    │  1. Test & Lint (all branches)        │
                    │  2. Build (all branches)               │
                    │  3. Deploy to AWS (main only)          │
                    └────────┬──────────────────┬────────────┘
                             │                  │
                    ┌────────▼──────┐  ┌───────▼──────────┐
                    │   Ubuntu 22   │  │  AWS Account     │
                    │ (CI runner)   │  │  (276362266002)  │
                    └───────────────┘  └───────┬──────────┘
                                               │
                              ┌────────────────┼────────────────┐
                              │                │                │
                       ┌──────▼──────┐ ┌─────▼─────┐ ┌────────▼──────────┐
                       │   S3 Bucket │ │ CloudFront│ │ Route53 (DNS)    │
                       │ (web build) │ │(CDN)      │ │ chrismarasco.io  │
                       └─────────────┘ └───────────┘ └──────────────────┘
```

## Deployment Flow

### 1. Local Development
- Work on `fix/disable-claude-api-on-web` feature branch
- Test locally with `flutter run -d chrome`
- Commit changes with descriptive messages

### 2. Create Pull Request
- Push branch to GitHub
- Create PR to `main`
- **GitHub Actions triggers**:
  - ✅ Runs `dart format .` (auto-commits formatting)
  - ✅ Runs `flutter analyze` (must pass)
  - ✅ Runs health check tests (must pass)
  - ✅ Builds Flutter web app
  - ❌ Does NOT deploy (only test + build on PR)

### 3. Code Review
- Reviewer checks changes in PR
- Request additional changes if needed
- Once approved, branch is ready to merge

### 4. Merge to Main
- Click "Squash and merge" or "Rebase and merge"
- Delete feature branch
- **GitHub Actions triggers again**:
  - ✅ Runs `dart format .`
  - ✅ Runs `flutter analyze`
  - ✅ Runs health check tests
  - ✅ Builds Flutter web app
  - ✅ **Deploys to AWS S3** (new!)
  - ✅ **Invalidates CloudFront cache** (new!)

### 5. Live Deployment
- App deployed to S3 bucket
- CloudFront cache cleared
- **Live in ~30-60 seconds** at:
  - https://greenfield.chrismarasco.io (custom domain)
  - https://d3814txe1aqheb.cloudfront.net (CloudFront URL)

## CI/CD Pipeline Details

### Test & Lint Job (always runs)
```yaml
- dart format .          # Auto-format code
- flutter analyze        # Static analysis (must pass)
- flutter test           # Health check tests (must pass)
- codecov upload         # Coverage metrics
```

**Failure handling**: If any step fails, workflow stops and PR is blocked.

### Build Job (always runs, after test passes)
```yaml
- flutter build web --release --dart-define="AI_PROXY_URL=https://greenfield.chrismarasco.io/api/claude"
- Upload build artifacts to GitHub (5 day retention)
```

**Optimization**: Includes tree-shaking of unused icons/fonts for smaller bundle.

### Deploy Job (main branch only)
```yaml
# Only runs when:
# - GitHub Actions are running
# - Event is 'push' (not pull_request)
# - Branch is 'refs/heads/main'

- AWS configure credentials  # Using secrets
- aws s3 sync build/web/ s3://bucket/ --delete
- aws cloudfront create-invalidation --paths "/*"
```

**Result**: App live in seconds.

## Required Setup

Before this workflow works, you must:

1. **Configure AWS Secrets** (see `.github/SECRETS_CHECKLIST.md`):
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_S3_BUCKET`
   - `AWS_CLOUDFRONT_DISTRIBUTION_ID`

2. **Create IAM User** with S3 + CloudFront permissions (policy in `GITHUB_ACTIONS_SETUP.md`)

3. **Test the workflow**:
   - Push a test commit to feature branch
   - Create PR and verify Actions run
   - Merge to main and verify deployment

## Monitoring Deployments

### View Workflow Runs
1. Go to `Actions` tab in GitHub
2. Select `CI/CD Pipeline` workflow
3. Click on the latest run
4. View each job's logs

### View Live App
- Custom domain: https://greenfield.chrismarasco.io
- CloudFront: https://d3814txe1aqheb.cloudfront.net
- Check browser DevTools console for errors

### Check Deployment Logs
```bash
# View S3 sync logs
aws s3api head-object --bucket greenfield-web-prod-276362266002 --key index.html

# Check CloudFront invalidation status
aws cloudfront get-invalidation --distribution-id EWU6INWV925A --id <ID>

# Monitor CloudFront activity
aws cloudfront list-invalidations --distribution-id EWU6INWV925A
```

## Troubleshooting

### PR Actions fail on analyzer
- **Fix**: Run `flutter analyze` locally before pushing
- Commit the required fixes

### PR Actions fail on tests
- **Fix**: Run `flutter test test/core/services/health_check/` locally
- Fix test failures before pushing

### Deploy fails with AWS error
- **Check**: Are secrets correctly configured?
- **Check**: Does IAM user have S3 + CloudFront permissions?
- **View logs**: Go to Actions tab and see detailed error messages

### Deploy completes but app still shows old version
- **Issue**: CloudFront cache might not have invalidated
- **Fix**: Wait 60 seconds and refresh page
- **Manual**: `aws cloudfront create-invalidation --distribution-id EWU6INWV925A --paths "/*"`

## Security Notes

✅ **Encrypted secrets**: AWS credentials stored as GitHub encrypted secrets
✅ **Least privilege**: IAM user has minimal required permissions
✅ **No hardcoded values**: Credentials passed via secrets, not in code
✅ **Limited scope**: Deploy only happens on main branch, from Actions only
✅ **Audit trail**: All deployments logged in GitHub Actions + AWS CloudTrail

## Next Steps

1. **Before merging this PR**:
   - Go to Settings → Secrets and variables → Actions
   - Add the 4 AWS secrets (see `SECRETS_CHECKLIST.md`)
   - Test with a small PR

2. **After merging**:
   - All commits to main automatically deploy
   - Monitor first few deployments to verify smooth operation
   - Update this doc if workflow changes

3. **Future improvements**:
   - Add Slack/Discord notifications on deploy success/failure
   - Add performance monitoring (Lighthouse)
   - Add manual approval before deploy to production
   - Add database migrations if backend is added

## Workflow Files

- `.github/workflows/ci-cd.yml` - Main workflow definition
- `.github/GITHUB_ACTIONS_SETUP.md` - Comprehensive setup guide
- `.github/SECRETS_CHECKLIST.md` - Quick secrets setup checklist
- `.github/DEPLOYMENT_WORKFLOW.md` - This file
