
# 🚀 AI Infrastructure Automation Framework

### Production-Style AWS Infrastructure Automation using Bash & AWS CLI

![AWS](https://img.shields.io/badge/AWS-CLI-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-Scripting-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![DevOps](https://img.shields.io/badge/DevOps-Automation-blue?style=for-the-badge)
![Platform Engineering](https://img.shields.io/badge/Platform-Engineering-success?style=for-the-badge)
![AWS CLI](https://img.shields.io/badge/Infrastructure-Automation-red?style=for-the-badge)

---

A modular AWS Infrastructure Automation Framework built using **Bash** and **AWS CLI** that provisions production-style cloud infrastructure following Infrastructure-as-Code and Platform Engineering principles.

</div>

---

# 📖 Table of Contents

- Overview
- Architecture
- Features
- Technology Stack
- Project Structure
- Infrastructure Provisioned
- Workflow
- Installation
- Configuration
- Usage
- Example Output
- Screenshots
- Skills Demonstrated
- Future Enhancements
- Author

---

# 🌟 Overview

This project demonstrates how to automate AWS infrastructure using modular Bash scripts.

Instead of writing one large shell script, the framework is designed with reusable libraries for:

- Configuration
- Validation
- Logging
- State Management
- Networking
- Security
- Compute

The framework provisions AWS resources in an idempotent manner, ensuring existing resources are reused instead of recreated.

---

# 🏗 Architecture

```text
                    Internet
                        │
                Internet Gateway
                        │
        ┌──────────────────────────────┐
        │          AWS VPC             │
        │       10.0.0.0/16            │
        │                              │
        │  Public Route Table          │
        │            │                 │
        │            ▼                 │
        │  Public Subnet               │
        │    10.0.1.0/24               │
        │            │                 │
        │     Security Group           │
        │            │                 │
        │      Amazon Linux EC2        │
        └──────────────────────────────┘
```

---

# ✨ Features

## Infrastructure Provisioning

- Amazon VPC
- Internet Gateway
- Public Subnet
- Route Table
- Route Association
- Security Group
- EC2 Instance
- Key Pair
- Dynamic Amazon Linux AMI Discovery

---

## Framework Features

- Modular Shell Architecture
- Infrastructure State Management
- Resource Tagging
- Validation Framework
- Logging Framework
- Idempotent Provisioning
- Infrastructure Summary
- Reusable Shell Libraries

---

# 🛠 Technology Stack

| Category | Technologies |
|-----------|-------------|
| Cloud | AWS |
| Compute | Amazon EC2 |
| Networking | VPC, IGW, Route Table, Subnet |
| Security | Security Groups |
| Automation | Bash |
| CLI | AWS CLI |
| Version Control | Git |
| Repository | GitHub |

---

# 📁 Project Structure

```text
ai-shell-automation/

├── aws-vpc-generator
│
├── generated
│   ├── generated_destroy.sh
│   └── generated_vpc.sh
│
├── prompts
│   ├── prompt.txt
│   └── destroy_prompt.txt
│
├── python
│   ├── generate_vpc_script.py
│   └── generate_destroy_script.py
│
├── scripts
│   ├── create_vpc.sh
│   ├── destroy_vpc.sh
│   └── lib
│       ├── aws.sh
│       ├── compute.sh
│       ├── config.sh
│       ├── logging.sh
│       ├── networking.sh
│       ├── security.sh
│       ├── state.sh
│       ├── tagging.sh
│       └── validation.sh
│
├── state
│   └── infrastructure.env
│
└── README.md
```

---

# ☁ AWS Resources Created

The framework provisions:

- Amazon VPC
- Internet Gateway
- Public Subnet
- Route Table
- Route Association
- Security Group
- Amazon Linux EC2 Instance
- SSH Key Pair

---

# 🔄 Provisioning Workflow

```text
Configuration

↓

Validation

↓

Create / Reuse VPC

↓

Create / Reuse Internet Gateway

↓

Create / Reuse Public Subnet

↓

Create / Reuse Route Table

↓

Associate Route Table

↓

Discover Latest Amazon Linux AMI

↓

Create / Reuse Key Pair

↓

Create / Reuse Security Group

↓

Launch / Reuse EC2

↓

Save Infrastructure State

↓

Display Infrastructure Summary
```

---

# 🚀 Installation

Clone the repository

```bash
git clone https://github.com/darshanpawar47/ai-shell-automation.git

cd ai-shell-automation
```

Install AWS CLI

Configure credentials

```bash
aws configure
```

Verify

```bash
aws sts get-caller-identity
```

---

# ⚙ Configuration

Configuration is centralized in:

```
scripts/lib/config.sh
```

Example:

```bash
REGION="ap-south-1"

VPC_CIDR="10.0.0.0/16"

PUBLIC_SUBNET_CIDR="10.0.1.0/24"

INSTANCE_TYPE="t3.micro"
```

---

# ▶ Running the Framework

Provision Infrastructure

```bash
cd aws-vpc-generator/scripts

bash create_vpc.sh
```

Destroy Infrastructure

```bash
bash destroy_vpc.sh
```

---

# 📋 Example Output

```text
====================================================
AI Infrastructure Automation Framework
====================================================

Environment Validation

✓ AWS CLI
✓ AWS Credentials
✓ Region Verification

Networking

✓ VPC
✓ Internet Gateway
✓ Public Subnet
✓ Route Table

Security

✓ Security Group

Compute

✓ Amazon Linux AMI
✓ Key Pair
✓ EC2 Instance

Infrastructure Summary

Provisioning Completed Successfully
```

---

# 📷 Screenshots

## GitHub Repository

```
docs/screenshots/01-github-home.png
```

## Project Structure

```
docs/screenshots/02-project-structure.png
```

## Prompt Engineering

```
docs/screenshots/03-prompt-engineering.png
```

## AI Generated Script

```
docs/screenshots/05-ai-generated-script.png
```

## Production Script

```
docs/screenshots/06-production-script.png
```

## Successful Provisioning

```
docs/screenshots/07-terminal-success.png
```

## AWS Resources

```
docs/screenshots/08-vpc-created.png

09-internet-gateway.png

10-resource-tags.png
```

---

# 💼 Skills Demonstrated

- AWS Networking
- Amazon EC2
- Bash Scripting
- AWS CLI
- Infrastructure Automation
- Infrastructure as Code
- Platform Engineering Principles
- Cloud Networking
- Git & GitHub
- Shell Script Modularization
- State Management
- Resource Tagging
- Production Logging
- Validation Framework

---

# 🎯 Key Learning Outcomes

- Built reusable shell libraries
- Designed modular infrastructure automation
- Automated AWS networking
- Implemented idempotent provisioning
- Managed infrastructure state
- Applied production logging practices
- Automated EC2 provisioning using AWS CLI

---

# 🔮 Future Enhancements

- Private Subnet
- NAT Gateway
- Application Load Balancer
- Auto Scaling
- GitHub Actions CI/CD
- Terraform Support
- Multi-AZ Deployment

---

# 👨‍💻 Author

## Darshan Pawar

Senior DevOps | Platform Engineer | Cloud Engineer

### Expertise

- AWS
- Azure
- Kubernetes
- Docker
- Terraform
- GitHub Actions
- Jenkins
- Bash
- Linux
- Platform Engineering
- Infrastructure Automation

LinkedIn

https://www.linkedin.com/in/darshan-pawar-489ab615/

---

# ⭐ If you found this project useful, consider giving it a Star.
