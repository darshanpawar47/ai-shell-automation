#!/usr/bin/env bash

###############################################################################
# AWS VPC Provisioning Script
#
# Author      : Darshan Pawar
# Purpose     : Create a production-ready AWS VPC with Internet Gateway
# Version     : 2.0
###############################################################################

set -euo pipefail
source "$(dirname "$0")/lib/config.sh"
source "$(dirname "$0")/lib/logging.sh"
source "$(dirname "$0")/lib/validation.sh"
source "$(dirname "$0")/lib/aws.sh"

check_aws_cli
check_credentials
check_region

if get_vpc
then
    log_success "Reusing existing VPC."
else
    create_vpc
    tag_vpc
fi

if get_igw
then
    log_success "Reusing existing Internet Gateway."
else
    create_igw
    attach_igw
    tag_igw
fi

exit 0


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
# Logging
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
# Validation
########################################

check_aws_cli() {

    info "Checking AWS CLI installation..."

    if ! command -v aws >/dev/null 2>&1; then
        error "AWS CLI not found."
        exit 1
    fi

    success "AWS CLI found."
}

check_aws_credentials() {

    info "Checking AWS credentials..."

    if ! aws sts get-caller-identity \
        --region "$REGION" >/dev/null 2>&1; then

        error "AWS credentials are invalid."
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

        error "Invalid AWS Region."

        exit 1
    fi

    success "Region verified."
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

    success "VPC created."

    info "VPC ID : $VPC_ID"

    aws ec2 create-tags \
        --region "$REGION" \
        --resources "$VPC_ID" \
        --tags \
            Key=Name,Value="${PROJECT_NAME}-vpc" \
            Key=Environment,Value="$ENVIRONMENT"

    success "VPC tagged."
}

########################################
# Create Internet Gateway
########################################

create_internet_gateway() {

    info "Creating Internet Gateway..."

    IGW_ID=$(aws ec2 create-internet-gateway \
        --region "$REGION" \
        --query "InternetGateway.InternetGatewayId" \
        --output text)

    success "Internet Gateway created."

    info "Internet Gateway ID : $IGW_ID"

    info "Attaching Internet Gateway..."

    aws ec2 attach-internet-gateway \
        --region "$REGION" \
        --internet-gateway-id "$IGW_ID" \
        --vpc-id "$VPC_ID"

    success "Internet Gateway attached."

    aws ec2 create-tags \
        --region "$REGION" \
        --resources "$IGW_ID" \
        --tags \
            Key=Name,Value="${PROJECT_NAME}-igw" \
            Key=Environment,Value="$ENVIRONMENT"

    success "Internet Gateway tagged."
}

########################################
# Main
########################################

main() {

    info "=============================================="
    info "AWS VPC Provisioning Started"
    info "=============================================="

    check_aws_cli

    check_aws_credentials

    check_region

    success "Environment validation completed."

    create_vpc

    create_internet_gateway

    success "=============================================="
    success "AWS Infrastructure Created Successfully"
    success "=============================================="

    echo
    echo "VPC ID               : $VPC_ID"
    echo "Internet Gateway ID  : $IGW_ID"
    echo "Region               : $REGION"
    echo "CIDR                 : $VPC_CIDR"
    echo
}

main