#!/bin/bash

set -euo pipefail

REGION="us-east-1"
VPC_CIDR="10.0.0.0/16"
PUBLIC_SUBNET CIDR="10.0.1.0/24"
PRIVATE_SUBNET CIDR="10.0.2.0/24"

echo "Creating VPC..."
aws ec2 create-vpc --cidr-block $VPC_CIDR

echo "Waiting for VPC creation..."
while [ $? -ne 0 ]; do
    sleep 1
done

VPC_ID=$(aws ec2 describe-vpcs --filters "Name=resource-type,Values=vpc" --query 'Reservations[0].Tags[]' --output text | grep $REGION | cut -d ':' -f 2)

echo "Creating Internet Gateway..."
aws ec2 create-internet-gateway --vpc-id $VPC_ID

echo "Waiting for Internet Gateway creation..."
while [ $? -ne 0 ]; do
    sleep 1
done

INTERNET_GATEWAY_ID=$(aws ec2 describe-internet-gateways --filters "Name=resource-type,Values=internet-gateway" --query 'Reservations[0].Tags[]' --output text | grep $REGION | cut -d ':' -f 2)

echo "Creating Public Subnet..."
aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PUBLIC_SUBNET CIDR

echo "Waiting for Public Subnet creation..."
while [ $? -ne 0 ]; do
    sleep 1
done

Public_SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=resource-type,Values=subnet" --query 'Reservations[0].Tags[]' --output text | grep $REGION | cut -d ':' -f 2)

echo "Creating Private Subnet..."
aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PRIVATE_SUBNET CIDR

echo "Waiting for Private Subnet creation..."
while [ $? -ne 0 ]; do
    sleep 1
done

PRIVATE_SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=resource-type,Values=subnet" --query 'Reservations[0].Tags[]' --output text | grep $REGION | cut -d ':' -f 2)

echo "Creating Route Table..."
aws ec2 create-route-table --vpc-id $VPC_ID

echo "Waiting for Route Table creation..."
while [ $? -ne 0 ]; do
    sleep 1
done

ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --filters "Name=resource-type,Values=route-table" --query 'Reservations[0].Tags[]' --output text | grep $REGION | cut -d ':' -f 2)

echo "Creating Route..."
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block $VPC_CIDR --gateway-id $INTERNET_GATEWAY_ID

echo "Waiting for Route creation..."
while [ $? -ne 0 ]; do
    sleep 1
done

echo "Associating Route Table to Public Subnet..."
aws ec2 associate-subnet-to-route-table --subnet-id $Public_SUBNET_ID --route-table-id $ROUTE_TABLE_ID

echo "Associating Route Table to Private Subnet..."
aws ec2 associate-subnet-to-route-table --subnet-id $PRIVATE_SUBNET_ID --route-table-id $ROUTE_TABLE_ID

echo "Tagging resources..."
aws ec2 create-tags --resource-type vpc --resources $VPC_ID --tags Key=Name,Value=my-vpc
aws ec2 create-tags --resource-type internet-gateway --resources $INTERNET_GATEWAY_ID --tags Key=Name,Value=my-igw
aws ec2 create-tags --resource-type subnet --resources $Public_SUBNET_ID --tags Key=Name,Value=my-public-subnet
aws ec2 create-tags --resource-type subnet --resources $PRIVATE_SUBNET_ID --tags Key=Name,Value=my-private-subnet
aws ec2 create-tags --resource-type route-table --resources $ROUTE_TABLE_ID --tags Key=Name,Value=my-rt