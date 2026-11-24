# Multi-Environment DevOps Automation Project

## Project Overview

This project demonstrates an end-to-end DevOps deployment workflow using GitHub, Jenkins, Terraform, AWS, Ansible, and Docker.

The pipeline automates infrastructure provisioning and application deployment across three environments: DEV, UAT, and PROD.

## Architecture

```text
Developer
    |
    v
GitHub Repository
    |
    v
Jenkins Pipeline
    |
    +---- Terraform
    |       |
    |       +---- AWS EC2
    |       +---- Security Groups
    |       +---- S3 Remote State
    |
    +---- Ansible
    |       |
    |       +---- Install Docker
    |       +---- Configure Docker
    |
    +---- Docker
            |
            +---- Nginx Container
                    |
                    v
              Web Application
```

## Technologies Used

| Technology | Purpose |
|---|---|
| AWS EC2 | Infrastructure hosting |
| AWS S3 | Terraform remote state |
| DynamoDB | Terraform state locking |
| Terraform | Infrastructure as Code |
| Jenkins | CI/CD automation |
| GitHub | Source code management |
| Ansible | Configuration management |
| Docker | Containerization |
| Nginx | Web server |

## Environments

The pipeline supports three environments:

- DEV
- UAT
- PROD

Jenkins build parameters:

- `ENV`: dev / uat / prod
- `ACTION`: plan / apply / destroy

Each environment uses a separate Terraform state file stored in S3.

## Terraform Infrastructure

Terraform provisions:

- Ubuntu EC2 instances
- Environment-specific Security Groups
- HTTP access on port 80
- SSH access from the Jenkins Security Group

The Terraform backend uses Amazon S3 for remote state storage and DynamoDB for state locking.

## Jenkins Pipeline Stages

1. Checkout source code from GitHub.
2. Verify installed tools.
3. Run Terraform formatting.
4. Initialize Terraform backend.
5. Validate Terraform configuration.
6. Generate Terraform execution plan.
7. Request approval before applying changes.
8. Provision AWS infrastructure.
9. Execute Ansible playbook.
10. Install and configure Docker.
11. Build Docker image.
12. Run Nginx container.
13. Verify application availability.

## Ansible Configuration

Ansible connects to the provisioned EC2 instance using SSH.

The playbook:

- Waits for SSH connectivity.
- Updates the Ubuntu package cache.
- Installs Docker.
- Starts and enables Docker.
- Copies application files.
- Builds a Docker image.
- Runs the application container.

## Docker Application

The project uses an Nginx Alpine base image.

The application is exposed on port 80.

## Deployment Verification

The application was successfully deployed and verified through HTTP URLs in all three environments:

- DEV: Working
- UAT: Working
- PROD: Working

## Key Learning Outcomes

- Automated multi-environment infrastructure provisioning.
- Terraform remote state management.
- Jenkins parameterized pipelines.
- Infrastructure approval before deployment.
- Ansible-based configuration management.
- Docker image building and container deployment.
- Troubleshooting AWS IAM and Terraform state permissions.

## Repository Structure

```text
Terra-ec2/
│
├── ansible/
│   └── playbook.yml
│
├── docker/
│   ├── Dockerfile
│   └── index.html
│
├── envs/
│   ├── dev.tfvars
│   ├── uat.tfvars
│   └── prod.tfvars
│
├── .gitignore
├── .gitattributes
├── Jenkinsfile
├── provider.tf
├── variables.tf
├── main.tf
├── output.tf
└── README.md
```

## Important Notes

- Never commit AWS credentials, private keys, Terraform state files, or sensitive values to GitHub.
- Review Terraform plans before approving infrastructure changes.
- Monitor AWS resources to avoid unnecessary charges.
- Use the destroy action carefully and only after verifying the selected environment.