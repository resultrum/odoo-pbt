# CI/CD Pipeline Guide for Odoo Template

Complete documentation for the GitHub Actions CI/CD pipeline included with this template.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [What Gets Tested](#what-gets-tested)
3. [Workflows](#workflows)
4. [Configuration](#configuration)
5. [Usage](#usage)
6. [Troubleshooting](#troubleshooting)

---

## Overview

The Odoo Template includes a complete, production-ready CI/CD pipeline that automatically tests, validates, and builds your code on every push and pull request.

### Key Features

✅ **Code Quality Checks** - Black, isort, flake8 formatting and linting
✅ **Security Scanning** - Hardcoded secrets detection, .gitignore validation
✅ **Docker Build Verification** - Ensures your image builds correctly
✅ **Module Detection** - Automatically finds and reports custom modules
✅ **Odoo Module Testing** - Tests your custom modules with Docker + PostgreSQL
✅ **Coverage Reporting** - Code coverage metrics (integrated with Codecov)

---

## What Gets Tested

### 1. Code Quality (5 parallel jobs in CI)

The `ci.yml` workflow runs automatically on every push and pull request:

**Job 1: lint-and-test**
- Black formatting check
- isort import sorting
- flake8 PEP8 linting
- pytest on project structure tests
- Coverage reporting

**Job 2: security-check**
- Detects hardcoded secrets
- Validates .gitignore configuration

**Job 3: build-check**
- Tests Docker image builds successfully

**Job 4: module-scan**
- Detects all custom modules in `/addons/custom/`
- Reports module count and names

**Job 5: odoo-module-test**
- Sets up PostgreSQL 15 service
- Builds Docker image
- Installs custom modules
- Runs module tests with `--test-enable`

---

## Workflows

### 1. CI Workflow (`ci.yml`)

**Triggers**:
- Every push to: `main`, `develop`, `master-iteration*` branches
- Every pull request to: `main`, `develop`, `master-iteration*` branches

**What it does**:
1. Checks out code
2. Sets up Python 3.10+ environment
3. Validates code formatting (black, isort, flake8)
4. Runs pytest on structure tests
5. Scans for hardcoded secrets
6. Validates .gitignore
7. Tests Docker image build
8. Scans for Odoo modules
9. Tests modules with Docker + PostgreSQL

**Success Criteria**:
- ✅ All formatting checks pass
- ✅ All tests pass
- ✅ No hardcoded secrets found
- ✅ Docker image builds successfully
- ✅ Custom modules detected and tested

**Failure Actions**:
- ❌ PR cannot be merged if CI fails
- ❌ Email notification sent to committer
- ❌ Requires developer to fix and push again

### 2. Docker Build & Push Workflow (`docker-build-push.yml`)

**Triggers**:
- Merge to `main` branch
- Push to `master-iteration*` branches
- Git tags starting with `v*` (e.g., `v1.0.0`)

**What it does**:
1. Builds Docker image
2. Tags image based on branch/tag
3. Pushes to GitHub Container Registry (GHCR)

**Image Tagging Strategy**:

```
Scenario 1: Push to main
├── Image: ghcr.io/<organization>/<project>:latest
└── Use case: Production releases

Scenario 2: Push to master-iteration1.0
├── Image: ghcr.io/<organization>/<project>:master-iteration1.0
└── Use case: Staging environment

Scenario 3: Tag v1.0.0 on main
├── Images:
│   ├── ghcr.io/<organization>/<project>:v1.0.0
│   └── ghcr.io/<organization>/<project>:latest
└── Use case: Semantic versioning for production
```

**Authentication**: Uses `GITHUB_TOKEN` (no secrets to configure!)

---

## Configuration

### GitHub Secrets

The template uses `GITHUB_TOKEN` which is provided automatically by GitHub. **No manual secrets configuration needed for basic CI/CD!**

However, if you extend the workflows for custom deployments, you may want to add:

```
# For deploying to your server
DEPLOY_SSH_KEY = <SSH private key>
DEPLOY_HOST = <your.server.com>
DEPLOY_USER = <username>
```

### Local Testing with `act`

Test workflows locally before pushing:

```bash
# Install act
brew install act  # macOS
sudo apt install act  # Linux

# Run CI workflow
act push --job lint-and-test

# Run with all jobs
act push
```

---

## Usage

### For Developers

#### 1. Create a Feature Branch

```bash
git checkout -b feature/my-new-feature
```

#### 2. Make Changes and Test Locally

```bash
# Test code quality
black --check .
isort --check .
flake8 .

# Or use pre-commit hooks
git add .
git commit -m "feat: add my feature"  # Runs pre-commit hooks automatically
```

#### 3. Push to GitHub

```bash
git push -u origin feature/my-new-feature
```

#### 4. CI Runs Automatically

- GitHub Actions triggers
- 5 jobs run in parallel
- Results shown in PR status

#### 5. Fix Any Issues

```bash
# Fix code
black .
isort .
# ... make your changes ...

git add .
git commit -m "fix: address CI issues"
git push
```

#### 6. Merge When CI Passes

Once all checks pass ✅, merge to main via GitHub UI.

### For DevOps / Release Management

#### Building a Docker Image

```bash
# Image is built automatically on merge to main or master-iteration*
# Check GitHub Actions for build status

# Pulling a built image
docker pull ghcr.io/<organization>/<project>:latest
docker pull ghcr.io/<organization>/<project>:v1.0.0
```

#### Creating a Release

```bash
# Tag a commit
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tag to GitHub
git push origin v1.0.0

# Docker build and push happens automatically!
```

---

## Troubleshooting

### CI Fails: Code Formatting Issues

**Problem**: Black or isort checks fail

**Solution**:
```bash
# Auto-format code
black .
isort .

# Commit and push
git add .
git commit -m "style: auto-format code"
git push
```

### CI Fails: Flake8 Linting

**Problem**: Flake8 violations found

**Solution**:
1. Read the error message in GitHub Actions logs
2. Fix the issue in your code
3. Example fixes:
   - Remove unused imports: `import os  # noqa: F401` or delete
   - Line too long: Break into multiple lines
   - Missing docstring: Add docstring

### CI Fails: Docker Build

**Problem**: Docker image fails to build

**Solution**:
1. Check workflow logs for error message
2. Test locally: `docker build -t test:latest .`
3. Common issues:
   - Missing file in COPY command
   - Invalid Dockerfile syntax
   - Dependency not installable

### CI Fails: Module Tests

**Problem**: Custom module tests fail

**Solution**:
1. Check workflow logs for test output
2. Run locally: `docker-compose up -d && docker-compose exec web pytest tests/`
3. Check test files in: `addons/custom/<module>/tests/`

### GitHub Actions Not Triggering

**Problem**: Push code but CI doesn't run

**Solution**:
1. Verify branch name matches workflow triggers:
   - `main`, `develop`, or `master-iteration*`
2. Check `.github/workflows/` files exist
3. Verify `.github/workflows/ci.yml` has correct `on:` section

### Docker Image Not Pushed

**Problem**: Build passes but image not in GHCR

**Solution**:
1. Check branch: only `main`, `master-iteration*`, or tags push
2. Verify workflow completed successfully
3. Check GHCR: https://github.com/orgs/<organization>/packages
4. Check GitHub Actions logs for error

---

## How It All Works Together

```
Developer commits code
    ↓
GitHub detects push
    ↓
CI Workflow runs (5 jobs in parallel):
├─ lint-and-test: ✅ Checks formatting, runs tests
├─ security-check: ✅ Scans for secrets
├─ build-check: ✅ Verifies Docker builds
├─ module-scan: ✅ Lists custom modules
└─ odoo-module-test: ✅ Tests with PostgreSQL
    ↓
All checks pass? ✅
    ↓
Merge to main
    ↓
Docker Build Workflow:
├─ Build Docker image
├─ Tag as ghcr.io/org/project:latest
└─ Push to GHCR
    ↓
Image ready to deploy!
```

---

## Pre-commit Hooks

This template includes pre-commit hooks to catch issues before pushing:

```bash
# Hooks installed automatically on clone
# They run on: git commit

# Current hooks:
- black (Python formatting)
- isort (Import sorting)
- flake8 (Linting)
- trailing-whitespace
- end-of-file-fixer
- yaml-validate
```

To manually run hooks:

```bash
pre-commit run --all-files
```

---

## Integration with Your IDE

### PyCharm

1. Open Settings → Tools → Python Integrated Tools
2. Set Default test runner: `pytest`
3. Run tests directly in IDE: Alt+Shift+F10

### VS Code

1. Install Python extension
2. Select Python interpreter from docker-compose
3. Run tests with Flask extension

See `docs/PYCHARM_SETUP.md` for detailed PyCharm setup.

---

## Next Steps

1. **Clone and setup**: `./scripts/setup-new-project.sh <name> <module> <org>`
2. **Local development**: `docker-compose up -d`
3. **Make changes**: Edit code in `addons/custom/`
4. **Commit**: `git commit` (pre-commit hooks run automatically)
5. **Push**: `git push origin main` (CI triggers automatically)
6. **Monitor**: Check GitHub Actions tab for build status

---

**Document Version**: 2.0 (Template Edition)
**Last Updated**: 2025-11-18
**Status**: Production Ready
