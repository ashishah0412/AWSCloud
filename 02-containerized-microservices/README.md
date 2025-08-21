# Project 02: Containerized Microservices with ECS Fargate and Application Load Balancer

## Overview

This project focuses on deploying a containerized microservices application using Amazon Elastic Container Service (ECS) with AWS Fargate as the compute engine. The application will consist of multiple services exposed via an Application Load Balancer (ALB). This setup is a robust and scalable solution for running microservices without managing the underlying EC2 instances, as Fargate handles the server management.

## Architecture

The architecture for this project leverages AWS Fargate for serverless container execution, an Application Load Balancer for traffic distribution, and Amazon Elastic Container Registry (ECR) for Docker image storage. The key components and their interactions are as follows:

1.  **Amazon Elastic Container Registry (ECR):** A fully managed Docker container registry that makes it easy to store, manage, and deploy Docker container images. Each microservice will have its Docker image pushed to a dedicated ECR repository.

2.  **Amazon Elastic Container Service (ECS):** A highly scalable, high-performance container orchestration service that supports Docker containers. We will use ECS to define, run, and scale our microservices.

3.  **AWS Fargate:** A serverless compute engine for Amazon ECS that allows you to run containers without having to provision, configure, or scale clusters of virtual machines. Fargate eliminates the need to manage EC2 instances, patching, and scaling, allowing you to focus on your applications.

4.  **Amazon Virtual Private Cloud (VPC):** The network foundation for our microservices. It will include public and private subnets across multiple Availability Zones for high availability. Fargate tasks will run in private subnets, and the ALB will reside in public subnets.

5.  **Application Load Balancer (ALB):** Distributes incoming application traffic across multiple targets, such as ECS tasks. The ALB operates at the application layer (Layer 7) and supports path-based routing, host-based routing, and URL rewrites, making it ideal for microservices. It will expose the microservices to the internet.

6.  **Amazon CloudWatch:** Used for monitoring the health and performance of the ECS services, Fargate tasks, and ALB. It collects and tracks metrics, collects and monitors log files, and sets alarms.

7.  **AWS Identity and Access Management (IAM):** IAM roles will be used to grant necessary permissions to ECS tasks (Task Execution Role and Task Role) and the ALB to interact with other AWS services securely.

### Data Flow:

*   Users access the microservices application via the ALB's DNS name.
*   The ALB receives the request and, based on listener rules (e.g., path-based routing), forwards the request to the appropriate target group.
*   Each target group is associated with an ECS service, which runs one or more Fargate tasks.
*   The Fargate task processes the request and returns the response to the ALB.
*   The ALB sends the response back to the user.

## AWS Services Deep Dive and Insights

### Amazon Elastic Container Registry (ECR)

ECR is a managed Docker container registry that integrates with ECS, EKS, and other AWS services. It provides a secure, scalable, and reliable place to store your container images. Key insights:

*   **Security:** ECR supports private repositories, and images are encrypted at rest. Integration with IAM allows fine-grained access control.
*   **Integration with ECS/EKS:** ECR is tightly integrated with ECS and EKS, simplifying the deployment of containerized applications.
*   **Vulnerability Scanning:** ECR can automatically scan your container images for common vulnerabilities, providing an additional layer of security.
*   **Lifecycle Policies:** You can define lifecycle policies to automatically clean up old or unused images, helping to manage storage costs.

### Amazon Elastic Container Service (ECS) with AWS Fargate

ECS is a powerful container orchestration service. When combined with Fargate, it offers a serverless approach to running containers, abstracting away the underlying infrastructure management. Key insights:

*   **Fargate vs. EC2 Launch Types:** Fargate is the serverless option, where AWS manages the EC2 instances. The EC2 launch type gives you more control over the underlying infrastructure but requires you to manage the EC2 instances yourself. Fargate is generally preferred for its operational simplicity and cost-effectiveness for many workloads.
*   **Task Definitions:** A task definition is a blueprint for your application. It specifies the Docker image to use, CPU and memory requirements, networking mode, and other container-specific settings. It's crucial for defining how your microservices run.
*   **Services:** An ECS service maintains the desired count of tasks, running and maintaining your application. It can be configured to use an ALB for load balancing and integrates with CloudWatch for monitoring and auto-scaling.
*   **Networking Modes:** For Fargate, `awsvpc` network mode is used, which provides each task with its own elastic network interface (ENI) and a private IP address, allowing for more granular security group control.
*   **Service Connect:** A new feature that simplifies service discovery and connectivity for microservices on ECS, allowing services to communicate using short names and providing traffic observability.

### Application Load Balancer (ALB)

ALB is a flexible, Layer 7 load balancer that is well-suited for microservices and container-based applications. Key insights:

*   **Path-Based Routing:** ALB can route requests to different target groups based on the URL path. This is ideal for microservices, where different services might handle different API endpoints (e.g., `/users` to User Service, `/products` to Product Service).
*   **Host-Based Routing:** Similar to path-based routing, but based on the hostname in the request. Useful for hosting multiple applications on the same ALB.
*   **Target Groups:** ALB routes requests to target groups, which contain one or more registered targets (e.g., ECS tasks). Health checks are configured at the target group level to ensure traffic is only sent to healthy instances.
*   **Integration with ECS:** ALB automatically registers and deregisters ECS tasks as they are launched or terminated, simplifying service management.
*   **Listener Rules:** Listeners check for connection requests using the protocol and port that you configure. Rules define how the load balancer routes requests to its registered targets.

### Amazon Virtual Private Cloud (VPC)

The VPC provides a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define. For this project, a well-designed VPC is critical for security and connectivity. Key insights:

*   **Public and Private Subnets:** Public subnets contain resources that need to be accessible from the internet (like the ALB). Private subnets contain resources that should not be directly accessible from the internet (like Fargate tasks and databases). A NAT Gateway in the public subnet allows resources in private subnets to access the internet for updates or external services.
*   **Security Groups:** Act as virtual firewalls for your instances to control inbound and outbound traffic. They are stateful.
*   **Network ACLs:** Optional layer of security that acts as a stateless firewall for controlling traffic in and out of one or more subnets.

### Amazon CloudWatch

CloudWatch is a monitoring and observability service that provides data and actionable insights to monitor your applications, respond to system-wide performance changes, and optimize resource utilization. Key insights:

*   **Metrics:** CloudWatch collects metrics from ECS, Fargate, and ALB, providing insights into CPU utilization, memory utilization, request counts, latency, and more.
*   **Logs:** CloudWatch Logs can collect logs from your containers, allowing you to centralize and analyze application logs.
*   **Alarms:** You can set up alarms to notify you or take automated actions (e.g., trigger auto-scaling) when a metric crosses a predefined threshold.
*   **Dashboards:** Create custom dashboards to visualize key metrics and logs, providing a holistic view of your application's health.

### AWS Identity and Access Management (IAM)

IAM is crucial for securing your ECS environment. Key insights:

*   **Task Execution Role:** Grants the ECS agent permission to make AWS API calls on your behalf, such as pulling container images from ECR and publishing container logs to CloudWatch Logs.
*   **Task Role:** Grants permissions to the containers in your task to access AWS resources (e.g., DynamoDB, S3, SQS). This adheres to the principle of least privilege for your application code.
*   **ALB IAM Role:** While ALB itself doesn't directly use an IAM role for its operations, the ECS service linked to the ALB will need permissions to register and deregister targets with the ALB.

## Project Folder Structure

```
AWSCloud/
├── 02-containerized-microservices/
│   ├── infra/                  # Terraform code for AWS infrastructure
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── app/                    # Application code (e.g., simple Flask/Node.js microservices)
│   │   ├── service1/           # First microservice
│   │   │   ├── app.py
│   │   │   ├── Dockerfile
│   │   │   └── requirements.txt
│   │   ├── service2/           # Second microservice
│   │   │   ├── app.js
│   │   │   ├── Dockerfile
│   │   │   └── package.json
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

This workflow will manage the AWS infrastructure defined in the `infra/` directory using Terraform. It will consist of five manually triggered jobs, similar to Project 01:

*   **`init`**: Initializes the Terraform working directory.
*   **`validate`**: Validates the Terraform configuration files.
*   **`plan`**: Generates and displays an execution plan.
*   **`apply`**: Applies the changes defined in the Terraform plan. Requires manual approval.
*   **`destroy`**: Destroys the AWS infrastructure managed by Terraform. Requires manual approval.

*(The content of `infra-pipeline.yml` will be similar to Project 01, with the `working-directory` adjusted to `./AWSCloud/02-containerized-microservices/infra`)*

### `app-pipeline.yml` (Application CI/CD)

This workflow will handle the building of Docker images, pushing them to ECR, and updating the ECS service definitions. It will be triggered on pushes to the `main` branch within the `app/` directory.

```yaml
name: Application CI/CD Pipeline - Microservices

on:
  push:
    branches:
      - main
    paths:
      - 'AWSCloud/02-containerized-microservices/app/**'

jobs:
  build-and-deploy-service1:
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

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build and push Docker image for Service 1
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: service1-repo
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG ./AWSCloud/02-containerized-microservices/app/service1
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

      - name: Update ECS Service 1
        run: |
          aws ecs update-service \
            --cluster YOUR_ECS_CLUSTER_NAME \
            --service YOUR_SERVICE1_NAME \
            --force-new-deployment

  build-and-deploy-service2:
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

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build and push Docker image for Service 2
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: service2-repo
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG ./AWSCloud/02-containerized-microservices/app/service2
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

      - name: Update ECS Service 2
        run: |
          aws ecs update-service \
            --cluster YOUR_ECS_CLUSTER_NAME \
            --service YOUR_SERVICE2_NAME \
            --force-new-deployment
```

**Note:** Replace `YOUR_ECS_CLUSTER_NAME`, `YOUR_SERVICE1_NAME`, and `YOUR_SERVICE2_NAME` with your actual ECS cluster and service names after infrastructure provisioning. The Terraform code will output these values.

This concludes the detailed design and documentation for Project 02. The next step will be to develop the actual Terraform and application code based on this design.

