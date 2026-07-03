#!/usr/bin/env bash

###############################################################################
# Compute Library
#
# Responsibilities
# - AMI Discovery
# - Key Pair Management
# - EC2 Instance Management (Future)
###############################################################################

###############################################################################
# Get Latest Amazon Linux 2023 AMI
###############################################################################

get_latest_ami() {

    log_section "Amazon Linux AMI"

    log_info "Discovering latest Amazon Linux 2023 AMI..."

    AMI_ID=$(aws ec2 describe-images \
        --owners amazon \
        --region "$REGION" \
        --filters \
            "Name=name,Values=al2023-ami-*-x86_64" \
            "Name=state,Values=available" \
        --query "sort_by(Images,&CreationDate)[-1].ImageId" \
        --output text)

    if [[ -z "$AMI_ID" || "$AMI_ID" == "None" ]]; then
        log_error "Unable to discover Amazon Linux 2023 AMI."
        exit 1
    fi

    log_success "Latest Amazon Linux 2023 AMI discovered."

    log_info "AMI ID : $AMI_ID"

    save_state "AMI_ID" "$AMI_ID"

}

###############################################################################
# Ensure Key Pair
###############################################################################

ensure_key_pair() {

    log_section "Key Pair"

    KEY_EXISTS=$(aws ec2 describe-key-pairs \
        --region "$REGION" \
        --key-names "$KEY_PAIR_NAME" \
        --query "KeyPairs[0].KeyName" \
        --output text 2>/dev/null || true)

    if [[ "$KEY_EXISTS" == "$KEY_PAIR_NAME" ]]; then

        log_success "Existing Key Pair found."

        save_state "KEY_PAIR_NAME" "$KEY_PAIR_NAME"

        return

    fi

    log_info "Creating Key Pair..."

    mkdir -p "$KEY_DIRECTORY"

    aws ec2 create-key-pair \
        --region "$REGION" \
        --key-name "$KEY_PAIR_NAME" \
        --query "KeyMaterial" \
        --output text \
        > "$KEY_DIRECTORY/$KEY_PAIR_NAME.pem"

    chmod 400 "$KEY_DIRECTORY/$KEY_PAIR_NAME.pem"

    log_success "Key Pair created."

    log_info "PEM saved to: $KEY_DIRECTORY/$KEY_PAIR_NAME.pem"

    save_state "KEY_PAIR_NAME" "$KEY_PAIR_NAME"

}