#!/usr/bin/env bash

###############################################################################
# Framework Paths
###############################################################################

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCRIPTS_DIR="$(cd "${LIB_DIR}/.." && pwd)"

PROJECT_ROOT="$(cd "${SCRIPTS_DIR}/.." && pwd)"

STATE_DIRECTORY="${PROJECT_ROOT}/state"

KEY_DIRECTORY="${PROJECT_ROOT}/keys"

###############################################################################
# Configuration
#
# Central configuration for the AWS Infrastructure Automation Framework.
###############################################################################

#############################################
# AWS Configuration
#############################################

export REGION="ap-south-1"

#############################################
# Network Configuration
#############################################

export VPC_NAME="ai-devops-vpc"
export IGW_NAME="ai-devops-igw"

export VPC_CIDR="10.0.0.0/16"

export PUBLIC_SUBNET_CIDR="10.0.1.0/24"
export PUBLIC_SUBNET_NAME="ai-devops-public-subnet"

export PUBLIC_SUBNET_AZ="ap-south-1a"
export PUBLIC_ROUTE_TABLE_NAME="ai-devops-public-rt"

export PRIVATE_SUBNET_CIDR="10.0.2.0/24"

###############################################################################
# NAT Gateway Configuration
###############################################################################

export ELASTIC_IP_NAME="ai-devops-eip"

export NAT_GATEWAY_NAME="ai-devops-nat"

export PRIVATE_SUBNET_NAME="ai-devops-private-subnet"

export PRIVATE_ROUTE_TABLE_NAME="ai-devops-private-rt"

export PRIVATE_SUBNET_CIDR="10.0.2.0/24"

export PRIVATE_SUBNET_AZ="ap-south-1a"


###############################################################################
# Security Configuration
###############################################################################

export SECURITY_GROUP_NAME="ai-devops-public-sg"

export SSH_PORT="22"

export HTTP_PORT="80"

# Lab only. Later we'll restrict this to your public IP.
export SSH_CIDR="0.0.0.0/0"

export HTTP_CIDR="0.0.0.0/0"

#############################################
# Project Metadata
#############################################

export PROJECT_NAME="AI-Shell-Automation"

export ENVIRONMENT="Lab"

export OWNER="Darshan"

export MANAGED_BY="ShellScript"

export VERSION="3.1"

#############################################
# Resource Tags
#############################################

export TAG_NAME="Name"

export TAG_PROJECT="Project"

export TAG_ENVIRONMENT="Environment"

export TAG_OWNER="Owner"

export TAG_MANAGED_BY="ManagedBy"

export TAG_VERSION="Version"

###############################################################################
# Compute Configuration
###############################################################################

export PUBLIC_SECURITY_GROUP_NAME="ai-devops-public-sg"

export EC2_NAME="ai-devops-web"

export INSTANCE_TYPE="t3.micro"

export KEY_PAIR_NAME="ai-devops-key"

# Leave empty for now
export AMI_ID=""

###############################################################################
# EC2 Configuration
###############################################################################

export EC2_NAME="ai-devops-web"

export INSTANCE_TYPE="t3.micro"

export ROOT_VOLUME_SIZE="20"

export ROOT_VOLUME_TYPE="gp3"

export ASSOCIATE_PUBLIC_IP="true"