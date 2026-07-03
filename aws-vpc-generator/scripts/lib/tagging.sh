#!/usr/bin/env bash

###############################################################################
# Tagging Library
###############################################################################

tag_resource() {

    local RESOURCE_ID="$1"
    local RESOURCE_NAME="$2"

    aws ec2 create-tags \
        --region "$REGION" \
        --resources "$RESOURCE_ID" \
        --tags \
            Key="$TAG_NAME",Value="$RESOURCE_NAME" \
            Key="$TAG_PROJECT",Value="$PROJECT_NAME" \
            Key="$TAG_ENVIRONMENT",Value="$ENVIRONMENT" \
            Key="$TAG_OWNER",Value="$OWNER" \
            Key="$TAG_MANAGED_BY",Value="$MANAGED_BY" \
            Key="$TAG_VERSION",Value="$VERSION"

}