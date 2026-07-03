#!/usr/bin/env bash

###############################################################################
# Infrastructure State Management Library
###############################################################################

STATE_FILE="${STATE_DIRECTORY}/infrastructure.env"

###############################################################################
# Ensure State File Exists
###############################################################################

initialize_state() {

    mkdir -p "$(dirname "$STATE_FILE")"

    touch "$STATE_FILE"

}

###############################################################################
# Save State
###############################################################################

save_state() {

    local KEY="$1"
    local VALUE="$2"

    initialize_state

    if grep -q "^${KEY}=" "$STATE_FILE"
    then
        sed -i "s|^${KEY}=.*|${KEY}=${VALUE}|" "$STATE_FILE"
    else
        echo "${KEY}=${VALUE}" >> "$STATE_FILE"
    fi

}

###############################################################################
# Load State
###############################################################################

load_state() {

    local KEY="$1"

    if [[ ! -f "$STATE_FILE" ]]
    then
        return
    fi

    grep "^${KEY}=" "$STATE_FILE" | cut -d '=' -f2-

}

###############################################################################
# Check if Key Exists
###############################################################################

state_exists() {

    local KEY="$1"

    grep -q "^${KEY}=" "$STATE_FILE" 2>/dev/null

}

###############################################################################
# Delete One Key
###############################################################################

delete_state() {

    local KEY="$1"

    if [[ -f "$STATE_FILE" ]]
    then
        sed -i "/^${KEY}=/d" "$STATE_FILE"
    fi

}

###############################################################################
# Clear Entire State
###############################################################################

clear_state() {

    > "$STATE_FILE"

}

###############################################################################
# Display State
###############################################################################

show_state() {

    log_section "Infrastructure State"

    if [[ -f "$STATE_FILE" ]]
    then
        cat "$STATE_FILE"
    else
        echo "No infrastructure state found."
    fi

}

###############################################################################
# Infrastructure Summary
###############################################################################

show_summary() {

    log_section "Infrastructure Summary"

    echo "VPC               : $(load_state VPC_ID)"
    echo "Public Subnet     : $(load_state PUBLIC_SUBNET_ID)"
    echo "Security Group    : $(load_state SECURITY_GROUP_ID)"
    echo "EC2 Instance      : $(load_state INSTANCE_ID)"
    echo "Instance State    : $(load_state INSTANCE_STATE)"
    echo "Public IP         : $(load_state PUBLIC_IP)"
    echo "Private IP        : $(load_state PRIVATE_IP)"
    echo "Availability Zone : $(load_state AVAILABILITY_ZONE)"
    echo "Region            : $(load_state REGION)"

    echo
    log_success "Infrastructure provisioning completed successfully."

}