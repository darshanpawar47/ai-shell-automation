#!/usr/bin/env bash

###############################################################################
# Networking Library
#
# Responsibilities
# - VPC
# - Internet Gateway
# - Subnets
# - Route Tables
# - Routes
# - Route Associations
###############################################################################

ensure_vpc() {

    log_section "VPC"

    VPC_ID=$(aws ec2 describe-vpcs \
        --region "$REGION" \
        --filters \
            "Name=tag:Project,Values=$PROJECT_NAME" \
        --query "Vpcs[0].VpcId" \
        --output text)

    if [[ "$VPC_ID" != "None" ]]
    then

        log_success "Existing VPC found."

        save_state "VPC_ID" "$VPC_ID"

        return

    fi

    log_info "Creating VPC..."

    VPC_ID=$(aws ec2 create-vpc \
        --region "$REGION" \
        --cidr-block "$VPC_CIDR" \
        --query "Vpc.VpcId" \
        --output text)

    tag_resource "$VPC_ID" "$VPC_NAME"

    log_success "VPC created."

    save_state "VPC_ID" "$VPC_ID"

}
#############################################
# Ensure Internet Gateway
#############################################

ensure_internet_gateway() {

    log_section "Internet Gateway"

    VPC_ID=$(load_state "VPC_ID")

    IGW_ID=$(aws ec2 describe-internet-gateways \
        --region "$REGION" \
        --filters \
            "Name=attachment.vpc-id,Values=$VPC_ID" \
        --query "InternetGateways[0].InternetGatewayId" \
        --output text)

    if [[ "$IGW_ID" != "None" ]]
    then

        log_success "Existing Internet Gateway found."

        save_state "IGW_ID" "$IGW_ID"

        return

    fi

    log_info "Creating Internet Gateway..."

    IGW_ID=$(aws ec2 create-internet-gateway \
        --region "$REGION" \
        --query "InternetGateway.InternetGatewayId" \
        --output text)

    aws ec2 attach-internet-gateway \
        --region "$REGION" \
        --internet-gateway-id "$IGW_ID" \
        --vpc-id "$VPC_ID"

    tag_resource "$IGW_ID" "$IGW_NAME"

    log_success "Internet Gateway created."

    save_state "IGW_ID" "$IGW_ID"

}

###############################################################################
# Delete Internet Gateway
###############################################################################

delete_internet_gateway() {

    log_section "Delete Internet Gateway"

    IGW_ID=$(load_state "IGW_ID")

    VPC_ID=$(load_state "VPC_ID")

    if [[ -z "$IGW_ID" ]]
    then
        log_warning "Internet Gateway not found in state."

        return
    fi

    log_info "Detaching Internet Gateway..."

    aws ec2 detach-internet-gateway \
        --internet-gateway-id "$IGW_ID" \
        --vpc-id "$VPC_ID" \
        --region "$REGION"

    log_success "Internet Gateway detached."

    log_info "Deleting Internet Gateway..."

    aws ec2 delete-internet-gateway \
        --internet-gateway-id "$IGW_ID" \
        --region "$REGION"

    log_success "Internet Gateway deleted."

}

###############################################################################
# Delete VPC
###############################################################################

delete_vpc() {

    log_section "Delete VPC"

    VPC_ID=$(load_state "VPC_ID")

    if [[ -z "$VPC_ID" ]]
    then
        log_warning "VPC not found in state."

        return
    fi

    log_info "Deleting VPC..."

    aws ec2 delete-vpc \
        --vpc-id "$VPC_ID" \
        --region "$REGION"

    log_success "VPC deleted."

}
###############################################################################
# Ensure Public Subnet
###############################################################################

ensure_public_subnet() {

    log_section "Public Subnet"

    VPC_ID=$(load_state "VPC_ID")

    SUBNET_ID=$(aws ec2 describe-subnets \
        --region "$REGION" \
        --filters \
            "Name=vpc-id,Values=$VPC_ID" \
            "Name=tag:Name,Values=$PUBLIC_SUBNET_NAME" \
        --query "Subnets[0].SubnetId" \
        --output text)

    if [[ "$SUBNET_ID" != "None" ]]
    then

        log_success "Existing Public Subnet found."

        save_state "PUBLIC_SUBNET_ID" "$SUBNET_ID"

        return

    fi

    log_info "Creating Public Subnet..."

    SUBNET_ID=$(aws ec2 create-subnet \
        --vpc-id "$VPC_ID" \
        --cidr-block "$PUBLIC_SUBNET_CIDR" \
        --availability-zone "$PUBLIC_SUBNET_AZ" \
        --region "$REGION" \
        --query "Subnet.SubnetId" \
        --output text)

    tag_resource "$SUBNET_ID" "$PUBLIC_SUBNET_NAME"

    aws ec2 modify-subnet-attribute \
    --subnet-id "$SUBNET_ID" \
    --map-public-ip-on-launch "{\"Value\":true}" \
    --region "$REGION"

    log_success "Public Subnet created."

    save_state "PUBLIC_SUBNET_ID" "$SUBNET_ID"
    log_info "Subnet ID : $SUBNET_ID"

}

###############################################################################
# Ensure Public Route Table
###############################################################################

ensure_route_table() {

    log_section "Public Route Table"

    VPC_ID=$(load_state "VPC_ID")

    ROUTE_TABLE_ID=$(aws ec2 describe-route-tables \
        --region "$REGION" \
        --filters \
            "Name=vpc-id,Values=$VPC_ID" \
            "Name=tag:Name,Values=$PUBLIC_ROUTE_TABLE_NAME" \
        --query "RouteTables[0].RouteTableId" \
        --output text)

    if [[ "$ROUTE_TABLE_ID" != "None" ]]
    then

        log_success "Existing Route Table found."

        save_state "ROUTE_TABLE_ID" "$ROUTE_TABLE_ID"

        return

    fi

    log_info "Creating Route Table..."

    ROUTE_TABLE_ID=$(aws ec2 create-route-table \
        --vpc-id "$VPC_ID" \
        --region "$REGION" \
        --query "RouteTable.RouteTableId" \
        --output text)

    tag_resource "$ROUTE_TABLE_ID" "$PUBLIC_ROUTE_TABLE_NAME"

    log_success "Route Table created."

    log_info "Route Table ID : $ROUTE_TABLE_ID"

    save_state "ROUTE_TABLE_ID" "$ROUTE_TABLE_ID"

}

###############################################################################
# Ensure Default Route
###############################################################################

ensure_default_route() {

    log_section "Default Route"

    ROUTE_TABLE_ID=$(load_state "ROUTE_TABLE_ID")
    IGW_ID=$(load_state "IGW_ID")

    ROUTE_EXISTS=$(aws ec2 describe-route-tables \
        --region "$REGION" \
        --route-table-ids "$ROUTE_TABLE_ID" \
        --query "RouteTables[0].Routes[?DestinationCidrBlock=='0.0.0.0/0'].GatewayId" \
        --output text)

    if [[ "$ROUTE_EXISTS" == "$IGW_ID" ]]; then

        log_success "Default route already exists."

        return

    fi

    log_info "Creating default route..."

    aws ec2 create-route \
        --route-table-id "$ROUTE_TABLE_ID" \
        --destination-cidr-block 0.0.0.0/0 \
        --gateway-id "$IGW_ID" \
        --region "$REGION"

    log_success "Default route created."

}

###############################################################################
# Associate Route Table
###############################################################################

ensure_route_association() {

    log_section "Route Table Association"

    ROUTE_TABLE_ID=$(load_state "ROUTE_TABLE_ID")
    SUBNET_ID=$(load_state "PUBLIC_SUBNET_ID")

    ASSOCIATION_ID=$(aws ec2 describe-route-tables \
        --route-table-ids "$ROUTE_TABLE_ID" \
        --region "$REGION" \
        --query "RouteTables[0].Associations[?SubnetId=='$SUBNET_ID'].RouteTableAssociationId" \
        --output text)

    if [[ "$ASSOCIATION_ID" != "None" && -n "$ASSOCIATION_ID" ]]; then

        log_success "Route Table already associated."

        save_state "ROUTE_ASSOCIATION_ID" "$ASSOCIATION_ID"

        return

    fi

    log_info "Associating Route Table..."

    ASSOCIATION_ID=$(aws ec2 associate-route-table \
        --route-table-id "$ROUTE_TABLE_ID" \
        --subnet-id "$SUBNET_ID" \
        --region "$REGION" \
        --query "AssociationId" \
        --output text)

    log_success "Route Table associated."

    save_state "ROUTE_ASSOCIATION_ID" "$ASSOCIATION_ID"

}

###############################################################################
# Ensure Elastic IP
###############################################################################

ensure_elastic_ip() {

    log_section "Elastic IP"

    # Implementation will be added next.

}