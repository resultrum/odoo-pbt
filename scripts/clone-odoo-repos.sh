#!/bin/bash

# =============================================================================
# Clone Odoo Enterprise/Community Repository with SSH
# =============================================================================
# Usage: ./scripts/clone-odoo-repos.sh
#
# This script:
# 1. Clones Odoo repository using SSH (supports private repos like resultrum/odoo)
# 2. Checks out the correct branch
# 3. Sets up git configuration
# 4. Verifies SSH connectivity before attempting clone
#
# Requires:
# - SSH key configured and added to ssh-agent
# - .env file with ODOO_REPO_URL and ODOO_REPO_BRANCH
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Load environment variables
if [ ! -f ".env" ]; then
  echo -e "${RED}❌ .env file not found!${NC}"
  echo "Please copy .env.example to .env and configure it:"
  echo "  cp .env.example .env"
  echo "  nano .env"
  exit 1
fi

# Source .env
export $(grep -v '^#' .env | xargs)

# Verify required variables
if [ -z "$ODOO_REPO_URL" ] || [ -z "$ODOO_REPO_BRANCH" ]; then
  echo -e "${RED}❌ ODOO_REPO_URL or ODOO_REPO_BRANCH not set in .env${NC}"
  exit 1
fi

ODOO_DIR="odoo-enterprise"

# ============================================================================
# Check SSH Connectivity
# ============================================================================

echo -e "${BLUE}🔍 Checking SSH connectivity...${NC}"

# Extract hostname from git URL (e.g., git@github.com:resultrum/odoo.git → github.com)
SSH_HOST=$(echo "$ODOO_REPO_URL" | sed -E 's|.*@([^:]+):.*|\1|')

if ! ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new -T "git@$SSH_HOST" &>/dev/null; then
  echo -e "${YELLOW}⚠️  SSH connectivity check failed for $SSH_HOST${NC}"
  echo ""
  echo -e "${YELLOW}Troubleshooting:${NC}"
  echo "1. Verify SSH key is added to ssh-agent:"
  echo "   ssh-add ~/.ssh/id_rsa"
  echo ""
  echo "2. Start ssh-agent if not running:"
  echo "   eval \"\$(ssh-agent -s)\""
  echo ""
  echo "3. Test SSH connection manually:"
  echo "   ssh -v git@$SSH_HOST"
  echo ""
  echo "4. For GitHub, ensure you have permission to the repository:"
  echo "   $ODOO_REPO_URL"
  echo ""
  # Don't exit - allow user to continue if they know what they're doing
fi

# ============================================================================
# Clone or Update Odoo Repository
# ============================================================================

if [ -d "$ODOO_DIR/.git" ]; then
  # Repository already exists - update it
  echo -e "${BLUE}📦 Updating Odoo repository...${NC}"
  cd "$ODOO_DIR"

  git fetch origin
  git checkout "$ODOO_REPO_BRANCH"
  git pull origin "$ODOO_REPO_BRANCH"

  echo -e "${GREEN}✅ Odoo repository updated${NC}"
  cd ..
else
  # Clone the repository
  echo -e "${BLUE}📥 Cloning Odoo repository...${NC}"
  echo "   URL: $ODOO_REPO_URL"
  echo "   Branch: $ODOO_REPO_BRANCH"
  echo ""

  git clone \
    --depth 1 \
    --branch "$ODOO_REPO_BRANCH" \
    "$ODOO_REPO_URL" \
    "$ODOO_DIR"

  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Odoo repository cloned successfully${NC}"
  else
    echo -e "${RED}❌ Failed to clone Odoo repository${NC}"
    echo ""
    echo -e "${YELLOW}Possible issues:${NC}"
    echo "1. SSH key not authorized for this repository"
    echo "2. Repository URL is incorrect: $ODOO_REPO_URL"
    echo "3. Branch doesn't exist: $ODOO_REPO_BRANCH"
    echo ""
    echo -e "${YELLOW}Solutions:${NC}"
    echo "1. Check SSH key permissions in GitHub/GitLab"
    echo "2. Verify repository URL in .env"
    echo "3. Verify branch exists: git ls-remote $ODOO_REPO_URL | grep $ODOO_REPO_BRANCH"
    exit 1
  fi
fi

# ============================================================================
# Verify Repository Structure
# ============================================================================

echo -e "${BLUE}🔎 Verifying Odoo directory structure...${NC}"

if [ ! -f "$ODOO_DIR/odoo-bin" ] && [ ! -f "$ODOO_DIR/odoo.py" ]; then
  echo -e "${RED}❌ Odoo executable not found in $ODOO_DIR${NC}"
  echo "Expected: $ODOO_DIR/odoo-bin or $ODOO_DIR/odoo.py"
  exit 1
fi

if [ ! -d "$ODOO_DIR/addons" ]; then
  echo -e "${RED}❌ Odoo addons directory not found in $ODOO_DIR${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Odoo directory structure verified${NC}"

# ============================================================================
# Display Summary
# ============================================================================

echo ""
echo -e "${GREEN}═════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Odoo Repository Setup Complete!${NC}"
echo -e "${GREEN}═════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Repository Information:${NC}"
echo "  URL:    $(cd $ODOO_DIR && git remote get-url origin)"
echo "  Branch: $(cd $ODOO_DIR && git rev-parse --abbrev-ref HEAD)"
echo "  Commit: $(cd $ODOO_DIR && git rev-parse --short HEAD)"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Start Docker containers:"
echo "   docker-compose up -d"
echo ""
echo "2. Access Odoo at: http://localhost:8069"
echo ""
echo "3. For debugging in PyCharm:"
echo "   - See docs/PYCHARM_DEBUGGING.md"
echo ""
