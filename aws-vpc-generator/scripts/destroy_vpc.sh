#!/usr/bin/env bash

###############################################################################
# AI Infrastructure Automation Framework
#
# Module : AWS Infrastructure Cleanup
# Version: 3.2
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/config.sh"
source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/validation.sh"
source "${SCRIPT_DIR}/lib/state.sh"
source "${SCRIPT_DIR}/lib/aws.sh"

initialize() {

    log_section "AI Infrastructure Cleanup"

}

main() {

    initialize

    validate_environment

    log_section "Current Infrastructure State"

    show_state
    echo
read -p "Type DELETE to destroy the infrastructure: " CONFIRM

if [[ "$CONFIRM" != "DELETE" ]]; then
    log_warning "Cleanup cancelled."
    exit 0
fi

    delete_internet_gateway

    delete_vpc

    delete_state "IGW_ID"

    delete_state "VPC_ID"

    log_section "Updated Infrastructure State"

    show_state

    log_success "Infrastructure cleanup completed successfully."

}

main "$@"