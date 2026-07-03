```bash
#!/bin/bash

REGION="your_region"

delete_lab_vpc() {
  local vpc_name_tag="ai-devops-vpc"
  
  # Validate AWS CLI installation
  if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed" >&2
    exit 1
  fi
  
  # Validate AWS credentials
  if ! aws --version &> /dev/null; then
    echo "AWS credentials are not valid" >&2
    exit 1
  fi
  
  # Log start of script
  log_info "Deleting lab VPC resources"
  
  # Find VPC by Name tag
  local vpc=$(aws ec2 describe-vpcs --query 'Vpcs[]|{VpcId}' --output text --filters "Name=tag:Name,Values=$vpc_name_tag" --region $REGION)
  
  if [ -n "$vpc" ]; then
    
    # Find Internet Gateway attached to VPC
    local ig=$(aws ec2 describe-internet-gateways --query 'InternetGateways[]|{InternetGatewayId}' --output text --filters "Name=attachment-depth,Values=0" --region $REGION)
    
    if [ -n "$ig" ]; then
        
      # Detach Internet Gateway
      aws ec2 detach-internet-gateway --internet-gateway-id $ig --vpc-id $(aws ec2 describe-vpcs --query 'Vpcs[]|{VpcId}' --output text --filters "Name=tag:Name,Values=$vpc_name_tag" --region $REGION) --region $REGION
      
      # Delete Internet Gateway
      aws ec2 delete-internet-gateway --internet-gateway-id $ig --region $REGION
      
      # Log success of deletion
      log_success "Deleted Internet Gateway"
      
    else
      # Log error if no Internet Gateway found
      log_error "No Internet Gateway attached to VPC"
    fi
    
  else
    # Log error if VPC not found
    log_error "VPC $vpc_name_tag not found in region $REGION"
  fi
  
  # Log end of script
}

log_info() {
  echo "$(date): ${1}"
}

log_success() {
  echo "$(date): ${1} (SUCCESS)"
}

log_error() {
  echo "$(date): ${1} (ERROR)"
}

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  delete_lab_vpc
fi
```