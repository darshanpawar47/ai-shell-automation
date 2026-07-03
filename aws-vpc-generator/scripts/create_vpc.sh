#!/usr/bin/env bash

###############################################################################
# AI Infrastructure Automation Framework
#
# Module : AWS VPC Provisioning
# Version: 3.1
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/config.sh"
source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/validation.sh"
source "${SCRIPT_DIR}/lib/state.sh"
source "${SCRIPT_DIR}/lib/tagging.sh"

# Domain Libraries
source "${SCRIPT_DIR}/lib/networking.sh"
source "${SCRIPT_DIR}/lib/security.sh"
source "${SCRIPT_DIR}/lib/compute.sh"

# Common AWS Utilities
source "${SCRIPT_DIR}/lib/aws.sh"
###############################################################################
# Initialize Framework
###############################################################################

initialize() {

    log_section "AI Infrastructure Automation Framework"

    save_state "PROJECT" "$PROJECT_NAME"
    save_state "REGION" "$REGION"

}

###############################################################################
# Main
###############################################################################

main() {

    initialize

    validate_environment

    ensure_vpc

    ensure_internet_gateway

    ensure_public_subnet

    ensure_route_table

    ensure_default_route

    ensure_route_association

    get_latest_ami

    ensure_key_pair

    ensure_security_group

    show_state

    log_section "Provisioning Completed"

}

main "$@"