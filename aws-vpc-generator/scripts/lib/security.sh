#!/usr/bin/env bash

#!/usr/bin/env bash

###############################################################################
# Security Library
#
# Responsibilities
# - Security Groups
###############################################################################

###############################################################################
# Ensure Security Group
###############################################################################

ensure_security_group() {

    log_section "Security Group"

    VPC_ID=$(load_state "VPC_ID")

    SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
        --region "$REGION" \
        --filters \
            "Name=vpc-id,Values=$VPC_ID" \
            "Name=group-name,Values=$SECURITY_GROUP_NAME" \
        --query "SecurityGroups[0].GroupId" \
        --output text)

    if [[ "$SECURITY_GROUP_ID" != "None" ]]; then

        log_success "Existing Security Group found."

        save_state "SECURITY_GROUP_ID" "$SECURITY_GROUP_ID"

        return

    fi

    log_info "Creating Security Group..."

    SECURITY_GROUP_ID=$(aws ec2 create-security-group \
        --region "$REGION" \
        --group-name "$SECURITY_GROUP_NAME" \
        --description "AI DevOps Public Security Group" \
        --vpc-id "$VPC_ID" \
        --query "GroupId" \
        --output text)

    tag_resource "$SECURITY_GROUP_ID" "$SECURITY_GROUP_NAME"

    log_info "Adding SSH rule..."

    aws ec2 authorize-security-group-ingress \
        --region "$REGION" \
        --group-id "$SECURITY_GROUP_ID" \
        --protocol tcp \
        --port "$SSH_PORT" \
        --cidr "$SSH_CIDR"

    log_info "Adding HTTP rule..."

    aws ec2 authorize-security-group-ingress \
        --region "$REGION" \
        --group-id "$SECURITY_GROUP_ID" \
        --protocol tcp \
        --port "$HTTP_PORT" \
        --cidr "$HTTP_CIDR"

    log_success "Security Group created."

    save_state "SECURITY_GROUP_ID" "$SECURITY_GROUP_ID"

}