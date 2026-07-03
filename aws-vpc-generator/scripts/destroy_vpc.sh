#!/bin/bash

set -euo pipefail

#############################################
# Configuration
#############################################

REGION="ap-south-1"
VPC_NAME="ai-devops-vpc"

#############################################
# Colors
#############################################

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

#############################################
# Logging
#############################################

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

#############################################
# Validation
#############################################

info "Checking AWS CLI..."

if ! command -v aws >/dev/null 2>&1; then
    error "AWS CLI not installed."
    exit 1
fi

success "AWS CLI found."

info "Checking AWS credentials..."

aws sts get-caller-identity >/dev/null

success "AWS credentials verified."

#############################################
# Find VPCs
#############################################

info "Searching for VPCs with Name tag: ${VPC_NAME}"

VPCS=$(aws ec2 describe-vpcs \
    --region "$REGION" \
    --filters "Name=tag:Name,Values=${VPC_NAME}" \
    --query "Vpcs[].VpcId" \
    --output text)

if [ -z "$VPCS" ]; then
    success "No matching VPCs found."
    exit 0
fi

#############################################
# Delete each VPC
#############################################

for VPC_ID in $VPCS
do

    echo
    info "Processing VPC: $VPC_ID"

    #########################################
    # Find attached Internet Gateway
    #########################################

    IGW_ID=$(aws ec2 describe-internet-gateways \
        --region "$REGION" \
        --filters "Name=attachment.vpc-id,Values=${VPC_ID}" \
        --query "InternetGateways[0].InternetGatewayId" \
        --output text)

    if [ "$IGW_ID" != "None" ] && [ -n "$IGW_ID" ]; then

        info "Detaching Internet Gateway: $IGW_ID"

        aws ec2 detach-internet-gateway \
            --internet-gateway-id "$IGW_ID" \
            --vpc-id "$VPC_ID" \
            --region "$REGION"

        success "Internet Gateway detached."

        info "Deleting Internet Gateway..."

        aws ec2 delete-internet-gateway \
            --internet-gateway-id "$IGW_ID" \
            --region "$REGION"

        success "Internet Gateway deleted."

    else
        info "No Internet Gateway attached."
    fi

    #########################################
    # Delete VPC
    #########################################

    info "Deleting VPC..."

    aws ec2 delete-vpc \
        --vpc-id "$VPC_ID" \
        --region "$REGION"

    success "Deleted VPC: $VPC_ID"

done

echo
echo "==============================================="
success "Cleanup completed successfully."
echo "==============================================="