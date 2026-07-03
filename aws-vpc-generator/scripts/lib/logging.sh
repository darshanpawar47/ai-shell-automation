#!/usr/bin/env bash

###############################################################################
# Logging Library
###############################################################################

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

log_info() {
    echo "$(timestamp) [INFO] $1"
}

log_success() {
    echo "$(timestamp) [SUCCESS] $1"
}

log_warning() {
    echo "$(timestamp) [WARNING] $1"
}

log_error() {
    echo "$(timestamp) [ERROR] $1"
}

log_section() {

    echo
    echo "===================================================="
    echo "$1"
    echo "===================================================="

}