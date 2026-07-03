#!/usr/bin/env bash

###############################################################################
# Validation Library
###############################################################################

check_aws_cli() {

    log_info "Checking AWS CLI installation..."

    if ! command -v aws >/dev/null 2>&1
    then
        log_error "AWS CLI is not installed."
        exit 1
    fi

    log_success "AWS CLI found."

}

check_credentials() {

    log_info "Checking AWS credentials..."

    if ! aws sts get-caller-identity \
        --region "$REGION" >/dev/null 2>&1
    then
        log_error "AWS credentials are invalid."
        exit 1
    fi

    log_success "AWS credentials are valid."

}

check_region() {

    log_info "Checking AWS region..."

    if ! aws ec2 describe-regions \
        --region "$REGION" \
        --query "Regions[].RegionName" \
        --output text | grep -qw "$REGION"
    then
        log_error "Region '$REGION' is invalid."
        exit 1
    fi

    log_success "Region verified."

}

validate_environment() {

    log_section "Environment Validation"

    check_aws_cli

    check_credentials

    check_region

    log_success "Environment validation completed."

}

###############################################################################
# Validate EC2 Dependencies
###############################################################################

validate_ec2_dependencies() {

    log_section "EC2 Pre-flight Validation"

    VPC_ID=$(load_state "VPC_ID")
    PUBLIC_SUBNET_ID=$(load_state "PUBLIC_SUBNET_ID")
    SECURITY_GROUP_ID=$(load_state "SECURITY_GROUP_ID")
    AMI_ID=$(load_state "AMI_ID")
    KEY_PAIR_NAME=$(load_state "KEY_PAIR_NAME")

    [[ -z "$VPC_ID" ]] && {
        log_error "VPC not found."
        exit 1
    }

    [[ -z "$PUBLIC_SUBNET_ID" ]] && {
        log_error "Public Subnet not found."
        exit 1
    }

    [[ -z "$SECURITY_GROUP_ID" ]] && {
        log_error "Security Group not found."
        exit 1
    }

    [[ -z "$AMI_ID" ]] && {
        log_error "AMI not found."
        exit 1
    }

    [[ -z "$KEY_PAIR_NAME" ]] && {
        log_error "Key Pair not found."
        exit 1
    }

    log_success "EC2 pre-flight validation passed."

}