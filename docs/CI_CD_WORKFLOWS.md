# CI/CD Workflows - Automated Testing & Deployment

Ce document décrit les workflows GitHub Actions configurés pour le template Odoo.

---

## 📊 Workflows Configurés

### 1. **CI.yml** - Tests & Code Quality
**Déclenché par**: Push sur `main/develop`, Pull requests
**Durée**: ~5-10 minutes

#### Tâches:
- ✅ **Tests Python** (Python 3.10 & 3.11)
  - Exécute pytest sur les modules
  - Génère rapport de couverture
  - Envoie vers Codecov

- ✅ **Linting** (Flake8, isort, Black)
  - Vérifie style du code
  - Vérifie ordre des imports
  - Vérifie formatage

- ✅ **Validation des Manifests**
  - Vérifie syntaxe des `__manifest__.py`
  - Valide structure JSON

- ✅ **Sécurité** (Trivy)
  - Scan vulnérabilités
  - Upload vers GitHub Security

---

### 2. **Docker.yml** - Build & Push to GHCR
**Déclenché par**: Push sur `main/develop`, Tags git, Workflow manual
**Durée**: ~10-15 minutes

#### Tâches:
- ✅ **Build Docker Image**
  - Construit l'image de dev
  - Tag avec branch name
  - Tag `latest` pour main

- ✅ **Build Production Image**
  - Construit `Dockerfile.prod` pour main
  - Tag `prod-latest`

- ✅ **Push vers GHCR**
  - Push automatique vers GitHub Container Registry
  - Disponible pour tous les contributeurs

- ✅ **Scan de sécurité**
  - Analyse l'image Docker
  - Report vulnérabilités

#### Image Registry:
```
ghcr.io/resultrum/odoo-template:main
ghcr.io/resultrum/odoo-template:latest
ghcr.io/resultrum/odoo-template:v1.2.3  (pour les tags)
ghcr.io/resultrum/odoo-template:prod-latest
```

---

### 3. **Validate.yml** - Configuration Validation
**Déclenché par**: Push sur `main/develop`, Pull requests
**Durée**: ~2-3 minutes

#### Tâches:
- ✅ **Docker Compose Validation**
  - Vérifie syntaxe `.yml`
  - Teste composition multi-fichiers

- ✅ **Dockerfile Validation**
  - Vérifie syntaxe Dockerfile
  - Hadolint checks

- ✅ **Environment Validation**
  - Vérifie format `.env.example`
  - Check variables requises

- ✅ **Script Validation**
  - Shellcheck sur `scripts/*.sh`
  - Vérifie permissions

- ✅ **Documentation Checks**
  - Vérifie README.md existe
  - Valide liens markdown

---

### 4. **Pre-commit.yml** - Code Quality Checks
**Déclenché par**: Push sur `main/develop`, Pull requests
**Durée**: ~3-5 minutes

#### Tâches:
- ✅ **Black** - Code formatting
- ✅ **isort** - Import sorting
- ✅ **Flake8** - Linting
- ✅ **Bandit** - Security checks
- ✅ **YAML/XML/JSON** - Syntax validation
- ✅ **Trailing whitespace** - Cleanup

---

## 🚀 Local Development with Pre-commit

### Installation

```bash
# Install pre-commit framework
pip install pre-commit

# Install git hooks
pre-commit install

# Run pre-commit on all files (optional)
pre-commit run --all-files
```

### Usage

```bash
# Automatically run on every commit
git commit -m "my changes"
# Pre-commit hooks run, fix issues, commit again if needed

# Manually run hooks
pre-commit run --all-files

# Skip hooks for emergency commits (not recommended!)
git commit --no-verify
```

---

## 📋 What Gets Checked

### Code Style
- Black formatting (100 char max line)
- isort import ordering
- Flake8 linting rules
- 4-space indentation

### Security
- Bandit - Python security issues
- No private keys in commit
- Large file detection (> 500KB)

### Configuration Files
- Dockerfile syntax (hadolint)
- Docker Compose validity
- YAML/JSON/TOML syntax
- Environment file validation

### Documentation
- Markdown file checking
- Script permissions
- Required files present

---

## 📊 Workflow Status in GitHub

### Viewing Results:
1. Go to repo → **Actions** tab
2. Select workflow from list
3. Click run to see details
4. Check individual job logs

### Understanding Status:
- 🟢 **Pass** - All checks passed
- 🟡 **Warning** - Some checks warned (allowed failures)
- 🔴 **Failed** - Build failed, fix needed
- ⚪ **Skipped** - Workflow didn't trigger

---

## 🔐 Required Secrets

Currently, no secrets are required for basic workflows.

For production deployment (optional):
- `REGISTRY_USERNAME` - GitHub username
- `REGISTRY_TOKEN` - GitHub personal access token (with `read:packages` scope)

---

## 📈 GitHub Container Registry (GHCR)

### Pull Latest Image:
```bash
docker pull ghcr.io/resultrum/odoo-template:latest
```

### Authenticate (optional for public images):
```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

### Use in docker-compose:
```yaml
services:
  web:
    image: ghcr.io/resultrum/odoo-template:latest
```

---

## 🧹 Common CI/CD Patterns

### On Every Commit:
```
Local pre-commit hooks → Git commit
```

### On Push to main/develop:
```
Git push → GitHub Actions:
  1. Run CI tests
  2. Run code quality checks
  3. Validate configuration
  4. Build & push Docker image
  5. Scan for vulnerabilities
```

### On Pull Request:
```
PR created → GitHub Actions:
  1. Run all CI workflows
  2. Report results on PR
  3. Block merge if failed
```

### On Tag (v*):
```
git tag v1.2.3 → GitHub Actions:
  1. Build Docker image
  2. Tag as v1.2.3
  3. Push to GHCR
```

---

## 📝 Tips & Best Practices

### For Developers:
1. **Always run tests locally** before pushing
2. **Use pre-commit** to catch issues early
3. **Check CI status** before merging PRs
4. **Read workflow logs** if tests fail

### For Maintainers:
1. **Monitor Actions** for failing workflows
2. **Update dependencies** regularly
3. **Review security scans** for vulnerabilities
4. **Document any exceptions** to CI rules

---

## 🔧 Troubleshooting

### Workflow Not Running?
- Check branch protection rules
- Verify workflow file syntax
- Check job triggers (on: push, pull_request, etc.)

### Tests Failing?
- Check logs in Actions tab
- Run locally: `python -m pytest`
- Check Python version compatibility

### Docker Build Failing?
- Check Dockerfile syntax
- Verify base image available
- Check docker-compose.yml validity

### Pre-commit Issues?
- Update: `pre-commit autoupdate`
- Clean cache: `pre-commit clean`
- Re-install: `pre-commit uninstall && pre-commit install`

---

## 📚 References

- [GitHub Actions Docs](https://docs.github.com/actions)
- [Pre-commit Framework](https://pre-commit.com/)
- [Docker GitHub Container Registry](https://docs.github.com/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

---

**Last updated**: 21 novembre 2025
**Status**: ✅ Production Ready
