#!/bin/bash
# ==============================================================
# MAXWELL OBSERVATORY -- MASTER PROVISIONING SCRIPT
# Phase 5: Full environment deployment automation
#
# This script deploys the complete MAXWELL Observatory
# infrastructure on AWS using Terraform.
#
# What gets deployed:
#   - 13 S3 buckets with encryption, versioning, public access block
#   - 11 lifecycle policies automating data tiering
#   - 8 IAM policies, groups, and users with scoped permissions
#   - 5 CloudWatch alarms with SNS alert routing
#   - CloudTrail audit trail writing to audit logs bucket
#   - CloudWatch operations dashboard
#
# Radiant parallel: This script is the equivalent of an
# Epic build deployment package -- a repeatable, documented
# process that provisions a complete environment from scratch.
#
# Prerequisites:
#   - AWS CLI installed and configured (aws configure)
#   - Terraform installed (>= 1.0)
#   - AWS account with appropriate permissions
#
# Usage:
#   chmod +x provision.sh
#   ./provision.sh
# ==============================================================

set -e

# --------------------------------------------------------------
# COLORS FOR OUTPUT
# --------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --------------------------------------------------------------
# BANNER
# --------------------------------------------------------------
echo ""
echo -e "${BLUE}=============================================================="
echo "  MAXWELL OBSERVATORY -- AWS Infrastructure Provisioning"
echo "  Electromagnetic Spectrum Data Management System"
echo "  Radiant parallel: Epic RIS deployment automation"
echo -e "==============================================================${NC}"
echo ""

# --------------------------------------------------------------
# STEP 1 -- PREFLIGHT CHECKS
# Verify required tools are installed before proceeding.
# --------------------------------------------------------------
echo -e "${YELLOW}[1/6] Running preflight checks...${NC}"

if ! command -v aws &> /dev/null; then
    echo -e "${RED}ERROR: AWS CLI not found. Install from https://aws.amazon.com/cli/${NC}"
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo -e "${RED}ERROR: Terraform not found. Install from https://terraform.io/downloads${NC}"
    exit 1
fi

echo -e "${GREEN}  AWS CLI found: $(aws --version)${NC}"
echo -e "${GREEN}  Terraform found: $(terraform version -json | python3 -c "import sys,json; print(json.load(sys.stdin)['terraform_version'])" 2>/dev/null || terraform version | head -1)${NC}"

# --------------------------------------------------------------
# STEP 2 -- VERIFY AWS CREDENTIALS
# --------------------------------------------------------------
echo ""
echo -e "${YELLOW}[2/6] Verifying AWS credentials...${NC}"

AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
AWS_USER=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null)

if [ -z "$AWS_ACCOUNT" ]; then
    echo -e "${RED}ERROR: AWS credentials not configured. Run: aws configure${NC}"
    exit 1
fi

echo -e "${GREEN}  Account: ${AWS_ACCOUNT}${NC}"
echo -e "${GREEN}  Identity: ${AWS_USER}${NC}"

# --------------------------------------------------------------
# STEP 3 -- CONFIRM DEPLOYMENT
# --------------------------------------------------------------
echo ""
echo -e "${YELLOW}[3/6] Deployment target summary:${NC}"
echo "  Region:      us-east-2 (US East Ohio)"
echo "  Project:     MAXWELL Observatory"
echo "  Resources:   13 S3 buckets, 8 IAM personas, 5 alarms"
echo "  Environment: prod"
echo ""
echo -e "${YELLOW}  Radiant parallel mapping:${NC}"
echo "  S3 buckets     -> DICOM image store + HL7 logs + PACS"
echo "  Lifecycle rules -> DICOM retention tiering by age"
echo "  IAM personas   -> Radiologist, Rad Tech, PACS Admin..."
echo "  CloudWatch     -> Critical value alerts + HIPAA audit"
echo ""

read -p "Deploy MAXWELL Observatory to AWS account ${AWS_ACCOUNT}? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Deployment cancelled.${NC}"
    exit 0
fi

# --------------------------------------------------------------
# STEP 4 -- TERRAFORM INIT
# --------------------------------------------------------------
echo ""
echo -e "${YELLOW}[4/6] Initializing Terraform...${NC}"

cd terraform

terraform init -upgrade

echo -e "${GREEN}  Terraform initialized successfully.${NC}"

# --------------------------------------------------------------
# STEP 5 -- TERRAFORM PLAN
# --------------------------------------------------------------
echo ""
echo -e "${YELLOW}[5/6] Generating deployment plan...${NC}"

terraform plan -out=maxwell.tfplan

echo -e "${GREEN}  Plan generated: maxwell.tfplan${NC}"

# --------------------------------------------------------------
# STEP 6 -- TERRAFORM APPLY
# --------------------------------------------------------------
echo ""
echo -e "${YELLOW}[6/6] Deploying MAXWELL Observatory...${NC}"

terraform apply maxwell.tfplan

echo ""
echo -e "${GREEN}=============================================================="
echo "  MAXWELL Observatory deployed successfully."
echo ""
echo "  Resources created:"
echo "  - 13 S3 buckets in us-east-2"
echo "  - 11 lifecycle policies"
echo "  - 8 IAM policies, groups, and users"
echo "  - 5 CloudWatch alarms"
echo "  - 1 CloudTrail audit trail"
echo "  - 1 CloudWatch dashboard"
echo ""
echo "  Next steps:"
echo "  1. Confirm SNS email subscription in your inbox"
echo "  2. Open CloudWatch dashboard: MAXWELL-Observatory-Operations"
echo "  3. Review IAM users in the AWS console"
echo ""
echo "  To destroy this environment:"
echo "  cd terraform && terraform destroy"
echo -e "==============================================================${NC}"
