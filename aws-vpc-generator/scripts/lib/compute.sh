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

###############################################################################
# Ensure EC2 Instance
###############################################################################

ensure_ec2() {

    log_section "EC2 Instance"

    INSTANCE_ID=$(aws ec2 describe-instances \
        --region "$REGION" \
        --filters \
            "Name=tag:Project,Values=$PROJECT_NAME" \
            "Name=instance-state-name,Values=pending,running,stopping,stopped" \
        --query "Reservations[0].Instances[0].InstanceId" \
        --output text)

    if [[ "$INSTANCE_ID" != "None" ]]; then

        log_success "Existing EC2 instance found."

        save_state "INSTANCE_ID" "$INSTANCE_ID"
        log_info "Waiting for EC2 instance to reach 'running' state..."

aws ec2 wait instance-running \
    --region "$REGION" \
    --instance-ids "$INSTANCE_ID"

log_success "EC2 instance is running."

INSTANCE_STATE=$(aws ec2 describe-instances \
    --region "$REGION" \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].State.Name" \
    --output text)

PUBLIC_IP=$(aws ec2 describe-instances \
    --region "$REGION" \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].PublicIpAddress" \
    --output text)

PRIVATE_IP=$(aws ec2 describe-instances \
    --region "$REGION" \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].PrivateIpAddress" \
    --output text)

AVAILABILITY_ZONE=$(aws ec2 describe-instances \
    --region "$REGION" \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].Placement.AvailabilityZone" \
    --output text)

INSTANCE_TYPE_VALUE=$(aws ec2 describe-instances \
    --region "$REGION" \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].InstanceType" \
    --output text)

save_state "INSTANCE_STATE" "$INSTANCE_STATE"
save_state "PUBLIC_IP" "$PUBLIC_IP"
save_state "PRIVATE_IP" "$PRIVATE_IP"
save_state "AVAILABILITY_ZONE" "$AVAILABILITY_ZONE"
save_state "INSTANCE_TYPE" "$INSTANCE_TYPE_VALUE"

        return

    fi

    log_info "No EC2 instance found."

    log_info "Launching EC2 instance..."

AMI_ID=$(load_state "AMI_ID")
PUBLIC_SUBNET_ID=$(load_state "PUBLIC_SUBNET_ID")
SECURITY_GROUP_ID=$(load_state "SECURITY_GROUP_ID")

INSTANCE_ID=$(aws ec2 run-instances \
    --region "$REGION" \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_PAIR_NAME" \
    --security-group-ids "$SECURITY_GROUP_ID" \
    --subnet-id "$PUBLIC_SUBNET_ID" \
    --associate-public-ip-address \
    --tag-specifications \
        "ResourceType=instance,Tags=[{Key=Name,Value=$EC2_NAME},{Key=Project,Value=$PROJECT_NAME},{Key=Environment,Value=$ENVIRONMENT},{Key=Owner,Value=$OWNER},{Key=ManagedBy,Value=$MANAGED_BY},{Key=Version,Value=$VERSION}]" \
    --query "Instances[0].InstanceId" \
    --output text)

log_success "EC2 instance launched."

log_info "Instance ID : $INSTANCE_ID"

save_state "INSTANCE_ID" "$INSTANCE_ID"

}

###############################################################################
# Delete EC2 Instance
###############################################################################

delete_ec2() {

    log_section "Delete EC2 Instance"

    INSTANCE_ID=$(load_state "INSTANCE_ID")

    if [[ -z "$INSTANCE_ID" ]]; then
        log_warning "No EC2 instance found in state."
        return
    fi

    log_info "Terminating EC2 instance..."

    aws ec2 terminate-instances \
        --region "$REGION" \
        --instance-ids "$INSTANCE_ID" \
        >/dev/null

    log_info "Waiting for EC2 termination..."

    aws ec2 wait instance-terminated \
        --region "$REGION" \
        --instance-ids "$INSTANCE_ID"

    log_success "EC2 instance terminated."

}