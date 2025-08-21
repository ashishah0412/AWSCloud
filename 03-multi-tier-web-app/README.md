# Project 03: Multi-Tier Web Application with EC2, RDS, and Auto Scaling

## Overview

This project demonstrates the deployment of a classic multi-tier web application on AWS, focusing on high availability, scalability, and robust data management. The architecture utilizes Amazon EC2 instances for the application tier, Amazon RDS for the database tier, and AWS Auto Scaling and Application Load Balancer (ALB) to ensure the application can handle varying loads and remain resilient to failures. This setup is a foundational pattern for many enterprise-grade web applications.

## Architecture

The multi-tier architecture separates the application into distinct logical and physical layers, enhancing modularity, scalability, and security. The primary components and their interactions are as follows:

1.  **Amazon Virtual Private Cloud (VPC):** The network foundation, configured with public and private subnets across multiple Availability Zones (AZs) to ensure high availability and fault tolerance. Public subnets will host the ALB, while private subnets will host EC2 instances and RDS databases.

2.  **Application Load Balancer (ALB):** Acts as the entry point for web traffic, distributing incoming requests across multiple EC2 instances in the web/application tier. The ALB provides advanced routing features, SSL termination, and health checks to ensure traffic is only sent to healthy instances.

3.  **Amazon EC2 (Web/Application Tier):** EC2 instances will host the web application code. These instances will be launched within private subnets and will not have direct internet access. All inbound traffic will be routed through the ALB. An Auto Scaling Group will manage the EC2 instances.

4.  **AWS Auto Scaling:** Automatically adjusts the number of EC2 instances in the web/application tier based on defined policies (e.g., CPU utilization, network in/out). This ensures the application can scale out during peak demand and scale in during low usage, optimizing performance and cost.

5.  **Amazon RDS (Database Tier):** A fully managed relational database service (e.g., PostgreSQL or MySQL) that will host the application's database. RDS handles routine database tasks like patching, backups, and scaling. A Multi-AZ deployment will be used for high availability and automatic failover.

6.  **Amazon CloudWatch:** Used for monitoring the health and performance of EC2 instances, RDS databases, ALB, and Auto Scaling Groups. It collects metrics, logs, and allows for setting alarms.

7.  **AWS Systems Manager (SSM):** Can be used for managing and automating operational tasks on EC2 instances, such as patching, running commands, and managing configurations. It can also be used for deploying application code to EC2 instances.

8.  **AWS Identity and Access Management (IAM):** IAM roles and policies will be used to grant necessary permissions to EC2 instances (for accessing other AWS services), RDS (for secure access), and other components.

### Data Flow:

*   Users access the web application via the ALB's DNS name.
*   The ALB receives the request and forwards it to a healthy EC2 instance in the Auto Scaling Group.
*   The EC2 instance processes the request, interacting with the RDS database for data storage and retrieval.
*   The RDS database processes the query and returns data to the EC2 instance.
*   The EC2 instance returns the response to the ALB.
*   The ALB sends the response back to the user.

## AWS Services Deep Dive and Insights

### Amazon EC2

Amazon EC2 provides resizable compute capacity in the cloud. It's the backbone for running virtual servers. Key insights for this project:

*   **Instance Types:** Choosing the right instance type (e.g., `t3.micro`, `m5.large`) is crucial for performance and cost optimization. It depends on the application's CPU, memory, storage, and networking requirements.
*   **Amazon Machine Images (AMIs):** AMIs provide the information required to launch an instance, including the operating system, application server, and applications. Custom AMIs can be created for faster instance launches with pre-configured software.
*   **User Data:** Scripts can be passed as user data to EC2 instances during launch to automate initial setup tasks, such as installing software, configuring web servers, or deploying application code.
*   **Security Groups:** Act as virtual firewalls at the instance level, controlling inbound and outbound traffic. It's critical to configure them to allow only necessary traffic (e.g., HTTP/HTTPS from ALB, SSH from bastion host).

### Amazon RDS

Amazon RDS makes it easy to set up, operate, and scale a relational database in the cloud. It supports several database engines, including MySQL, PostgreSQL, MariaDB, Oracle, and SQL Server. Key insights:

*   **Managed Service:** RDS automates administrative tasks like hardware provisioning, database setup, patching, and backups, freeing up time for application development.
*   **Multi-AZ Deployments:** For high availability and disaster recovery, Multi-AZ deployments create a synchronous standby replica in a different Availability Zone. In case of an outage, RDS automatically fails over to the standby replica.
*   **Read Replicas:** For read-heavy workloads, read replicas can be created to offload read traffic from the primary database instance, improving read performance and scalability.
*   **Parameter Groups and Option Groups:** Allow for fine-grained control over database engine configuration and enable features like Transparent Data Encryption (TDE) or integration with other AWS services.
*   **Security:** RDS instances should be placed in private subnets. Access should be controlled via security groups, allowing connections only from the application tier EC2 instances.

### AWS Auto Scaling

AWS Auto Scaling monitors your applications and automatically adjusts capacity to maintain steady, predictable performance at the lowest possible cost. Key insights:

*   **Auto Scaling Group (ASG):** A collection of EC2 instances that are treated as a logical grouping for the purposes of automatic scaling and management. The ASG ensures that a specified number of instances are always running.
*   **Launch Configurations/Templates:** Define the instance type, AMI, security groups, and user data for instances launched by the ASG. Launch Templates are the newer, more flexible option.
*   **Scaling Policies:** Define when and how the ASG should scale. Common policies include:
    *   **Target Tracking Scaling:** Adjusts capacity to maintain a specific metric (e.g., average CPU utilization) at a target value.
    *   **Step Scaling:** Adds or removes instances based on a set of scaling adjustments, in response to a CloudWatch alarm.
    *   **Simple Scaling:** Similar to step scaling but with a cooldown period.
*   **Health Checks:** ASGs perform health checks on instances and replace unhealthy ones, contributing to application resilience.
*   **Integration with ALB:** ASGs can register and deregister instances with an ALB, ensuring that only healthy instances receive traffic.

### Application Load Balancer (ALB)

As discussed in Project 02, ALB is a Layer 7 load balancer. In a multi-tier web application, it plays a crucial role in distributing traffic to the web/application tier. Key insights:

*   **Listener Rules:** Define how incoming requests are routed to target groups. For a web application, listeners typically listen on ports 80 (HTTP) and 443 (HTTPS).
*   **Target Groups:** EC2 instances in the Auto Scaling Group will be registered as targets in an ALB target group. The ALB performs health checks on these targets.
*   **SSL/TLS Termination:** ALB can handle SSL/TLS encryption and decryption, offloading this compute-intensive task from the EC2 instances.
*   **Sticky Sessions:** Can be configured to ensure that requests from a user are consistently routed to the same instance, which can be important for applications that maintain session state on the server.

### AWS Systems Manager (SSM)

AWS Systems Manager provides a unified interface to view operational data from multiple AWS services and allows you to automate operational tasks across your AWS resources. Key insights:

*   **Run Command:** Securely and remotely manage the configuration of your managed instances.
*   **State Manager:** Maintains a consistent configuration across your instances.
*   **Patch Manager:** Automates the process of patching managed instances with security updates and other bug fixes.
*   **Parameter Store:** Securely stores configuration data and secrets. Can be used to store database credentials or API keys that your application needs.
*   **Session Manager:** Provides secure and auditable instance management without the need to open inbound ports, manage SSH keys, or use bastion hosts.

## Project Folder Structure

```
AWSCloud/
├── 03-multi-tier-web-app/
│   ├── infra/                  # Terraform code for AWS infrastructure
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── app/                    # Example application code (e.g., simple PHP/Python web app)
│   │   ├── web-app/            # Web application files
│   │   │   ├── index.php
│   │   │   └── config.php
│   ├── .github/                # GitHub Actions workflows
│   │   ├── workflows/
│   │   │   ├── infra-pipeline.yml    # Workflow for Terraform (Init, Validate, Plan, Apply, Destroy)
│   │   │   └── app-pipeline.yml      # Workflow for application deployment
│   ├── README.md               # Project-specific documentation (this file)
│   └── .gitignore              # Git ignore file
```

## GitHub Actions Workflows

This project will utilize two primary GitHub Actions workflows to automate the infrastructure provisioning and application deployment processes.

### `infra-pipeline.yml` (Terraform CI/CD)

This workflow will manage the AWS infrastructure defined in the `infra/` directory using Terraform. It will consist of five manually triggered jobs, similar to previous projects:

*   **`init`**: Initializes the Terraform working directory.
*   **`validate`**: Validates the Terraform configuration files.
*   **`plan`**: Generates and displays an execution plan.
*   **`apply`**: Applies the changes defined in the Terraform plan. Requires manual approval.
*   **`destroy`**: Destroys the AWS infrastructure managed by Terraform. Requires manual approval.

*(The content of `infra-pipeline.yml` will be similar to Project 01, with the `working-directory` adjusted to `./AWSCloud/03-multi-tier-web-app/infra`)*

### `app-pipeline.yml` (Application CI/CD)

This workflow will handle the deployment of the web application code to the EC2 instances managed by the Auto Scaling Group. This can be achieved using AWS CodeDeploy or AWS Systems Manager Run Command. For simplicity, we'll outline a basic approach using `aws s3 sync` and `aws ssm send-command`.

```yaml
name: Application CI/CD Pipeline - Multi-Tier Web App

on:
  push:
    branches:
      - main
    paths:
      - AWSCloud/03-multi-tier-web-app/app/**

jobs:
  deploy-app:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Upload application code to S3
        run: |
          aws s3 sync ./AWSCloud/03-multi-tier-web-app/app/web-app/ s3://YOUR_APP_CODE_S3_BUCKET_NAME/web-app/ --delete

      - name: Get EC2 Instance IDs from Auto Scaling Group
        id: get_instance_ids
        run: |
          INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
            --auto-scaling-group-names YOUR_ASG_NAME \
            --query "AutoScalingGroups[0].Instances[?LifecycleState==`InService`].InstanceId" \
            --output text)
          echo "instance_ids=$INSTANCE_IDS" >> $GITHUB_OUTPUT

      - name: Deploy application code to EC2 instances via SSM Run Command
        if: ${{ steps.get_instance_ids.outputs.instance_ids != '' }}
        run: |
          aws ssm send-command \
            --instance-ids ${{ steps.get_instance_ids.outputs.instance_ids }} \
            --document-name "AWS-RunShellScript" \
            --parameters commands="sudo apt update && sudo apt install -y apache2 php libapache2-mod-php php-mysql && sudo rm -rf /var/www/html/* && sudo aws s3 sync s3://YOUR_APP_CODE_S3_BUCKET_NAME/web-app/ /var/www/html/ && sudo systemctl restart apache2" \
            --comment "Deploy web application code"
```

**Note:** Replace `YOUR_APP_CODE_S3_BUCKET_NAME` and `YOUR_ASG_NAME` with your actual S3 bucket name (for code deployment) and Auto Scaling Group name after infrastructure provisioning. The Terraform code will output these values. The `ssm send-command` example assumes a Linux EC2 instance with Apache and PHP, and `aws cli` installed and configured on the instance.

This concludes the detailed design and documentation for Project 03. The next step will be to develop the actual Terraform and application code based on this design.

