#!/bin/bash

#############################################
# AWS Helper Functions
#############################################

get_vpc() {

    log_info "Checking if VPC already exists..."

    VPC_ID=$(aws ec2 describe-vpcs \
        --region "$REGION" \
        --filters "Name=tag:Name,Values=$VPC_NAME" \
        --query "Vpcs[0].VpcId" \
        --output text)

    if [[ "$VPC_ID" == "None" || -z "$VPC_ID" ]]; then

        log_warning "No existing VPC found."

        return 1

    fi

    log_success "Existing VPC found."

    log_info "VPC ID : $VPC_ID"

    return 0

}

create_vpc() {

    log_info "Creating VPC..."

    VPC_ID=$(aws ec2 create-vpc \
        --cidr-block "$VPC_CIDR" \
        --region "$REGION" \
        --query "Vpc.VpcId" \
        --output text)

    log_success "VPC created."

    log_info "VPC ID : $VPC_ID"

}

tag_vpc() {

    log_info "Tagging VPC..."

    aws ec2 create-tags \
        --resources "$VPC_ID" \
        --region "$REGION" \
        --tags Key=Name,Value="$VPC_NAME"

    log_success "VPC tagged."

}

#############################################
# Internet Gateway Functions
#############################################

get_igw() {

    log_info "Checking if Internet Gateway already exists..."

    IGW_ID=$(aws ec2 describe-internet-gateways \
        --region "$REGION" \
        --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
        --query "InternetGateways[0].InternetGatewayId" \
        --output text)

    if [[ "$IGW_ID" == "None" || -z "$IGW_ID" ]]; then
        log_warning "No Internet Gateway attached."
        return 1
    fi

    log_success "Existing Internet Gateway found."
    log_info "Internet Gateway ID : $IGW_ID"

    return 0
}

create_igw() {

    log_info "Creating Internet Gateway..."

    IGW_ID=$(aws ec2 create-internet-gateway \
        --region "$REGION" \
        --query "InternetGateway.InternetGatewayId" \
        --output text)

    log_success "Internet Gateway created."
    log_info "Internet Gateway ID : $IGW_ID"
}

attach_igw() {

    log_info "Attaching Internet Gateway..."

    aws ec2 attach-internet-gateway \
        --internet-gateway-id "$IGW_ID" \
        --vpc-id "$VPC_ID" \
        --region "$REGION"

    log_success "Internet Gateway attached."
}

tag_igw() {

    log_info "Tagging Internet Gateway..."

    aws ec2 create-tags \
        --resources "$IGW_ID" \
        --region "$REGION" \
        --tags Key=Name,Value="$IGW_NAME"

    log_success "Internet Gateway tagged."
}