#!/bin/bash

#############################################
# AWS Configuration
#############################################

export REGION="ap-south-1"

#############################################
# VPC Configuration
#############################################

export VPC_NAME="ai-devops-vpc"
export VPC_CIDR="10.0.0.0/16"

#############################################
# Public Subnet Configuration
#############################################

export PUBLIC_SUBNET_NAME="ai-public-subnet"
export PUBLIC_SUBNET_CIDR="10.0.1.0/24"

#############################################
# Private Subnet Configuration
#############################################

export PRIVATE_SUBNET_NAME="ai-private-subnet"
export PRIVATE_SUBNET_CIDR="10.0.2.0/24"

#############################################
# Internet Gateway
#############################################

export IGW_NAME="ai-igw"

#############################################
# Route Table
#############################################

export ROUTE_TABLE_NAME="ai-public-rt"

#############################################
# Project Metadata
#############################################

export PROJECT_NAME="AI-Shell-Automation"

export ENVIRONMENT="Lab"

export OWNER="Darshan"

export MANAGED_BY="ShellScript"

export VERSION="3.0"