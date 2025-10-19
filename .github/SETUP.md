# GitHub Actions Setup Guide

## 🎯 Objective
Set up cost-effective approval workflows that **don't consume GitHub Actions minutes** while waiting for approvals.

## 📋 Prerequisites

1. ✅ AWS OIDC Provider (already configured in `infra-state-resources/github-actions.tf`)
2. ✅ IAM Role for GitHub Actions (already configured)
3. GitHub repository with admin access

## 🔧 Setup Steps

### Step 1: Get AWS Role ARN

From your Terraform outputs:

```bash
cd infra-state-resources
terraform output github_actions_role_arn
```

Copy the ARN (format: `arn:aws:iam::ACCOUNT_ID:role/github-actions-terraform-dev`)

### Step 2: Add GitHub Repository Secrets

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secrets:

| Secret Name | Value | Description |
|------------|-------|-------------|
| `AWS_ROLE_ARN` | `arn:aws:iam::...` | IAM Role ARN from Step 1 |

### Step 3: Create GitHub Environments

This is the **KEY** to cost-effective approvals!

#### Create Development Environment (No approval needed)
1. Go to **Settings** → **Environments**
2. Click **New environment**
3. Name: `dev`
4. Leave protection rules empty (no approval needed for dev)
5. Click **Save protection rules**

#### Create Production Environment (Approval required)
1. Go to **Settings** → **Environments**
2. Click **New environment**
3. Name: `production`
4. Under **Deployment protection rules**:
   - ✅ Check **Required reviewers**
   - Add reviewers (select team members or yourself)
   - Set **Prevent self-review** (optional but recommended)
   - Set **Wait timer**: 5 minutes (optional - prevents immediate deployments)
5. Under **Deployment branches**:
   - Select **Protected branches only**
   - Or select specific branches like `main`
6. Click **Save protection rules**

#### Create Staging Environment (Optional)
Repeat the process above with:
- Name: `staging`
- 1 required reviewer

### Step 4: Configure Branch Protection (Optional but Recommended)

1. Go to **Settings** → **Branches**
2. Click **Add rule**
3. Branch name pattern: `main`
4. Enable:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (1-2 reviewers)
   - ✅ Require status checks to pass before merging
5. Save changes

### Step 5: Test the Workflow

#### Test with Manual Workflow:
```bash
# In GitHub UI:
# 1. Go to Actions tab
# 2. Select "Manual Approval Workflow"
# 3. Click "Run workflow"
# 4. Choose:
#    - Action: plan
#    - Environment: dev
# 5. Run workflow
# 6. Review the plan output
# 7. If good, run again with:
#    - Action: apply
#    - Environment: production (will require approval!)
```

#### Test with PR Workflow:
```bash
# On your local machine:
git checkout -b test-approval-workflow
# Make a small change to any .tf file
echo "# test" >> infra-network/README.md
git add .
git commit -m "test: approval workflow"
git push origin test-approval-workflow

# In GitHub UI:
# 1. Create a Pull Request
# 2. Workflow will automatically run terraform plan
# 3. Wait for approval gate (NO RUNNER COSTS!)
# 4. Approve in the Actions tab
# 5. Watch terraform apply execute
```

## 💰 Cost Savings

### ❌ Old Way (Expensive):
```
Plan: 2 minutes = $0.008
Waiting for approval: 60 minutes = $0.240 💸
Apply: 3 minutes = $0.012
────────────────────────────────
Total: 65 minutes = $0.260
```

### ✅ New Way (Cost-Effective):
```
Plan: 2 minutes = $0.008
Waiting for approval: 0 minutes = $0.000 ✨
Apply: 3 minutes = $0.012
────────────────────────────────
Total: 5 minutes = $0.020
```

**Savings**: 92% reduction in GitHub Actions costs! 🎉

### Real-world example:
- 50 deployments/month
- Average approval wait: 30 minutes
- Old cost: 50 × (5 min active + 30 min waiting) = 1,750 minutes = **$7.00/month**
- New cost: 50 × (5 min active + 0 min waiting) = 250 minutes = **$1.00/month**
- **Savings: $6.00/month per repo** (86% reduction)

For organizations with many repositories, this adds up quickly!

## 🔍 How It Works

### The Magic: Environment Protection Rules

When you use an environment with required reviewers:

```yaml
jobs:
  wait-for-approval:
    runs-on: ubuntu-latest
    environment: production  # 🎯 This line pauses the workflow
    steps:
      - run: echo "Approved!"
```

**What happens:**
1. Job reaches the `environment: production` line
2. GitHub **pauses** the workflow
3. **No runner is allocated** (no costs!)
4. Notification is sent to reviewers
5. When approved, GitHub **resumes** the workflow
6. Runner is allocated and continues
7. You only pay for active execution time

### Job Dependencies

```yaml
jobs:
  plan:
    runs-on: ubuntu-latest
    # ... runs immediately

  approval:
    needs: plan
    environment: production  # Pauses here, no cost
    # ...

  apply:
    needs: [plan, approval]  # Only runs after approval
    # ... runs after approval
```

## 📚 Workflow Files Explained

| File | Purpose | When to Use |
|------|---------|-------------|
| `terraform-deploy-with-approval.yml` | PR-triggered deployment with approval | Automatic deployments from PRs |
| `manual-approval-workflow.yml` | Manual plan/apply separation | When you want explicit control |
| `reusable-terraform.yml` | Reusable workflow template | Called by other workflows |
| `deploy-all-infra.yml` | Deploy multiple components | Deploy entire infrastructure stack |

## 🛡️ Security Best Practices

1. **Never skip approvals for production**: Always require reviewers
2. **Use OIDC**: Already configured, never use long-lived credentials
3. **Separate environments**: dev (auto), staging (1 reviewer), prod (2+ reviewers)
4. **Audit trail**: All approvals are logged in GitHub
5. **Least privilege**: Review IAM policies in `github-actions.tf`

## 🐛 Troubleshooting

### Issue: "Environment not found"
**Solution**: Create the environment in Settings → Environments

### Issue: "Approval not required"
**Solution**: Add required reviewers in environment settings

### Issue: "Unable to assume role"
**Solution**: Check that `AWS_ROLE_ARN` secret is correct and OIDC provider is configured

### Issue: "Workflow runs but skips apply"
**Solution**: Ensure the plan job outputs `has-changes=true` when there are actual changes

## 🎓 Additional Resources

- [GitHub Environments Documentation](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [Required Reviewers](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#required-reviewers)
- [Terraform GitHub Actions](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions)
- [AWS OIDC Guide](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

## ✅ Verification Checklist

- [ ] AWS OIDC Provider created
- [ ] IAM Role for GitHub Actions created
- [ ] `AWS_ROLE_ARN` secret added to GitHub
- [ ] `dev` environment created (no approvals)
- [ ] `production` environment created (with reviewers)
- [ ] Test workflow run successful
- [ ] Approval process tested
- [ ] Cost savings confirmed in Actions usage page

## 🎉 Next Steps

1. Customize the workflows for your specific needs
2. Add more environments (staging, qa, etc.)
3. Set up Slack/Teams notifications for approvals
4. Monitor GitHub Actions usage in Settings → Billing
5. Celebrate your cost savings! 🎊

