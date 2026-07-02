#!/usr/bin/env bash

###############################################################################
# AWS VPC Provisioning Script
#
# Author      : Darshan Pawar
# Purpose     : Create a production-ready AWS VPC using AWS CLI
# Version     : 1.0
###############################################################################

set -euo pipefail

########################################
# Configuration
########################################

REGION="ap-south-1"

VPC_CIDR="10.0.0.0/16"

PUBLIC_SUBNET_CIDR="10.0.1.0/24"

PRIVATE_SUBNET_CIDR="10.0.2.0/24"

PROJECT_NAME="ai-devops"

ENVIRONMENT="dev"

########################################
# Colors
########################################

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

########################################
# Logging Functions
########################################

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

########################################
# Validation Functions
########################################

check_aws_cli() {

    info "Checking AWS CLI installation..."

    if ! command -v aws >/dev/null 2>&1; then
        error "AWS CLI is not installed."
        exit 1
    fi

    success "AWS CLI found."
}

check_aws_credentials() {

    info "Checking AWS credentials..."

    if ! aws sts get-caller-identity \
        --region "$REGION" >/dev/null 2>&1; then

        error "AWS credentials are not configured or are invalid."
        exit 1
    fi

    success "AWS credentials are valid."
}

check_region() {

    info "Checking AWS region..."

    if ! aws ec2 describe-regions \
        --region "$REGION" \
        --query "Regions[].RegionName" \
        --output text | grep -qw "$REGION"; then

        error "Region '$REGION' is invalid."
        exit 1
    fi

    success "Region $REGION is valid."
}

########################################
# Create VPC
########################################

create_vpc() {

    info "Creating VPC..."

    VPC_ID=$(aws ec2 create-vpc \
        --region "$REGION" \
        --cidr-block "$VPC_CIDR" \
        --query "Vpc.VpcId" \
        --output text)

    success "VPC created successfully."

    info "VPC ID : $VPC_ID"

    info "Tagging VPC..."

    aws ec2 create-tags \
        --region "$REGION" \
        --resources "$VPC_ID" \
        --tags \
            Key=Name,Value="${PROJECT_NAME}-vpc" \
            Key=Environment,Value="$ENVIRONMENT"

    success "VPC tagged successfully."
}

########################################
# Main
########################################

main() {

    info "======================================="
    info "AWS VPC Provisioning Started"
    info "======================================="

    check_aws_cli

    check_aws_credentials

    check_region

    success "Environment validation completed."

    create_vpc

    success "======================================="
    success "AWS VPC Created Successfully"
    success "======================================="

    echo
    echo "VPC ID      : $VPC_ID"
    echo "Region      : $REGION"
    echo "CIDR Block  : $VPC_CIDR"
    echo
}

main