#!/bin/bash

#############################################
# Validation Functions
#############################################

check_aws_cli() {

    log_info "Checking AWS CLI installation..."

    if ! command -v aws >/dev/null 2>&1; then
        log_error "AWS CLI is not installed."
        exit 1
    fi

    log_success "AWS CLI found."
}

check_credentials() {

    log_info "Checking AWS credentials..."

    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        log_error "AWS credentials are invalid."
        exit 1
    fi

    log_success "AWS credentials are valid."
}

check_region() {

    log_info "Checking AWS region..."

    if ! aws ec2 describe-regions \
        --region "$REGION" >/dev/null 2>&1; then

        log_error "Region $REGION is invalid."

        exit 1

    fi

    log_success "Region verified."
}