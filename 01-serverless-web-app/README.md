# Project 01: Serverless Web Application with API Gateway, Lambda, and DynamoDB

## Overview

This project demonstrates the implementation of a serverless web application leveraging key AWS services: Amazon API Gateway, AWS Lambda, Amazon DynamoDB, Amazon S3 for static website hosting, and Amazon Route 53 for DNS management. The application will provide a basic backend API that interacts with a NoSQL database, and a simple frontend hosted on S3. This setup is a common pattern for building scalable, cost-effective, and highly available web applications without managing servers.

## Architecture

The architecture of this serverless web application is designed to be fully managed and event-driven, minimizing operational overhead. The core components and their interactions are as follows:

1.  **Amazon S3 (Static Website Hosting):** The frontend of the web application (HTML, CSS, JavaScript) will be hosted as a static website on an S3 bucket. S3 provides high availability, durability, and scalability for static content delivery.

2.  **Amazon Route 53:** A custom domain will be configured in Route 53 to point to the S3 static website and the API Gateway endpoint. This provides a user-friendly URL for accessing the application.

3.  **Amazon API Gateway:** This acts as the entry point for the backend API. It exposes RESTful endpoints that clients (the frontend or other applications) can call. API Gateway handles request routing, authentication, authorization, throttling, and caching. It integrates seamlessly with AWS Lambda.

4.  **AWS Lambda:** This is the compute service that executes the backend logic. When an API Gateway endpoint is invoked, it triggers a specific Lambda function. Lambda functions are stateless, run in response to events, and automatically scale with demand. For this project, Lambda functions will perform operations like reading from and writing to the DynamoDB table.

5.  **Amazon DynamoDB:** A fully managed NoSQL database service that provides fast and flexible performance with seamless scalability. It will store the application's data. DynamoDB is designed for high-performance applications that require single-digit millisecond latency at any scale.

6.  **AWS Identity and Access Management (IAM):** IAM roles and policies will be used to define permissions for Lambda functions to access DynamoDB and for API Gateway to invoke Lambda. This ensures that each service has only the necessary permissions to perform its function, adhering to the principle of least privilege.

### Data Flow:

*   Users access the web application via a custom domain configured in Route 53.
*   Route 53 directs requests for static content to the S3 bucket.
*   For API calls, Route 53 directs requests to the API Gateway endpoint.
*   API Gateway receives the request and invokes the appropriate AWS Lambda function.
*   The Lambda function executes the business logic, interacting with the DynamoDB table to retrieve or store data.
*   DynamoDB processes the request and returns the data to the Lambda function.
*   The Lambda function returns the response to API Gateway.
*   API Gateway sends the response back to the client (frontend).

## AWS Services Deep Dive and Insights

### Amazon S3 for Static Website Hosting

Amazon S3 is not just an object storage service; it's a powerful platform for hosting static websites. When configured for static website hosting, an S3 bucket can serve web pages, images, videos, and client-side scripts directly from the bucket. This eliminates the need for web servers, reducing costs and operational complexity. Key insights include:

*   **Cost-Effectiveness:** You only pay for storage and data transfer, which is significantly cheaper than running EC2 instances for web servers.
*   **Scalability and Availability:** S3 is designed for 99.999999999% (11 nines) durability and automatically scales to handle any amount of traffic, making it ideal for high-traffic static sites.
*   **Integration with CloudFront:** For enhanced performance, security, and global reach, S3 static websites are often fronted by Amazon CloudFront, a Content Delivery Network (CDN). CloudFront caches content at edge locations worldwide, reducing latency for end-users and providing DDoS protection. While not explicitly in the initial scope of this project, it's a crucial next step for production deployments.
*   **Bucket Policy for Public Access:** To serve content publicly, the S3 bucket must have a bucket policy that grants `s3:GetObject` permissions to `Everyone` (or specific IAM principals if access is restricted). Additionally, 


Block Public Access settings must be configured to allow public access.

### Amazon API Gateway

API Gateway is a fully managed service that makes it easy for developers to create, publish, maintain, monitor, and secure APIs at any scale. It acts as a 


“front door” for applications to access data, business logic, or functionality from your backend services. Key insights and best practices for API Gateway in a serverless context include:

*   **Edge-Optimized vs. Regional Endpoints:** For global applications, Edge-optimized endpoints (which use CloudFront) are generally preferred for lower latency. Regional endpoints are suitable for clients in the same AWS region or when using a custom CDN.
*   **API Types:** API Gateway supports REST APIs (HTTP and RESTful), WebSocket APIs (for real-time two-way communication), and HTTP APIs (a simpler, lower-latency, and cost-effective alternative to REST APIs for many use cases). For this project, a REST API or HTTP API will be used.
*   **Integration Types:** API Gateway can integrate with various backend services, including Lambda functions (Lambda Proxy Integration is common for serverless), HTTP endpoints, and AWS services. Lambda Proxy Integration simplifies the mapping of requests and responses between API Gateway and Lambda.
*   **Security:** API Gateway offers multiple authorization options, including IAM roles and policies, Amazon Cognito User Pools, and custom authorizers (Lambda functions). For this project, IAM policies will be used to control access to the API, and for public APIs, no authorization might be needed at the API Gateway level, relying on backend Lambda logic for validation.
*   **Throttling and Caching:** API Gateway allows you to set throttling limits to protect your backend services from too many requests and configure caching to reduce the number of calls to your backend, improving performance and reducing costs.

### AWS Lambda

AWS Lambda is a serverless compute service that runs your code in response to events and automatically manages the underlying compute resources. It allows you to run code without provisioning or managing servers. Insights and best practices for Lambda in serverless applications include:

*   **Event-Driven Architecture:** Lambda is at the heart of event-driven architectures. It can be triggered by a wide range of AWS services (API Gateway, S3, DynamoDB Streams, SQS, etc.) and custom events.
*   **Statelessness:** Lambda functions are inherently stateless. Any persistent data should be stored in external services like DynamoDB, S3, or RDS. This design promotes scalability and resilience.
*   **Cold Starts:** When a Lambda function is invoked for the first time or after a period of inactivity, it experiences a 


“cold start,” where AWS needs to provision a new execution environment. This can introduce latency. Best practices to mitigate cold starts include optimizing code for faster initialization, using provisioned concurrency for critical functions, and keeping package sizes small.
*   **Memory and CPU Allocation:** Lambda functions are allocated CPU proportionally to the memory configured. Optimizing memory settings can significantly impact performance and cost. It's crucial to test different memory configurations to find the optimal balance.
*   **Error Handling and Retries:** Implement robust error handling within Lambda functions and configure appropriate retry mechanisms. For asynchronous invocations, Lambda automatically retries failed invocations. For synchronous invocations (like from API Gateway), the client is responsible for retries.
*   **Logging and Monitoring:** Use Amazon CloudWatch Logs for logging Lambda function output and CloudWatch Metrics for monitoring performance. This is essential for debugging and understanding function behavior.

### Amazon DynamoDB

Amazon DynamoDB is a fully managed, serverless NoSQL database service that delivers single-digit millisecond performance at any scale. It's a key component in many serverless architectures due to its scalability, low latency, and operational simplicity. Key insights and best practices for DynamoDB include:

*   **Primary Keys:** The choice of primary key (partition key, or partition key and sort key) is crucial for performance. It determines how data is distributed and accessed. A well-designed primary key ensures even data distribution and efficient query patterns.
*   **Read/Write Capacity Modes:** DynamoDB offers two read/write capacity modes: On-Demand and Provisioned. On-Demand is suitable for unpredictable workloads, while Provisioned is cost-effective for predictable traffic. Choosing the right mode is essential for cost optimization.
*   **Global Tables:** For multi-region applications, DynamoDB Global Tables provide a fully managed, multi-master, multi-region replication solution, enabling fast local reads and writes for globally distributed applications.
*   **Indexes (Local Secondary Indexes and Global Secondary Indexes):** Use indexes to support different query patterns beyond the primary key. Local Secondary Indexes (LSIs) have the same partition key as the table but a different sort key. Global Secondary Indexes (GSIs) have a different partition key and can have a different sort key, allowing for more flexible querying across the entire table.
*   **Data Modeling:** Effective data modeling is paramount in DynamoDB. Unlike relational databases, denormalization and careful consideration of access patterns are often necessary to achieve optimal performance and cost efficiency. Avoid complex joins and focus on single-table design where possible.
*   **Streams:** DynamoDB Streams capture a time-ordered sequence of item-level modifications in a DynamoDB table. These streams can be used to trigger Lambda functions for real-time processing, data replication, or auditing.

### Amazon Route 53

Amazon Route 53 is a highly available and scalable cloud Domain Name System (DNS) web service. It connects user requests to internet applications running on AWS or on-premises. For serverless web applications, Route 53 plays a critical role in directing traffic to the S3 static website and API Gateway endpoints. Key insights include:

*   **Domain Registration and DNS Management:** Route 53 allows you to register domain names and manage DNS records (A, CNAME, MX, etc.) for your domains.
*   **Traffic Routing Policies:** Route 53 offers various routing policies, including Simple, Weighted, Latency, Failover, Geolocation, and Multivalue Answer. For this project, Simple or Alias records will be used to point to S3 and API Gateway. Failover routing is crucial for disaster recovery scenarios.
*   **Alias Records:** Alias records are a Route 53-specific extension to DNS. They provide a way to map your domain name to AWS resources (like S3 buckets, CloudFront distributions, or API Gateway custom domain names) without incurring DNS query charges and providing automatic health checks.
*   **Health Checks:** Route 53 can perform health checks on your resources and route traffic away from unhealthy endpoints, improving application availability.

### AWS Identity and Access Management (IAM)

AWS IAM is a web service that helps you securely control access to AWS resources. It enables you to manage users, groups, and roles, and define policies that specify what actions they can perform on which resources. In a serverless application, IAM is fundamental for securing interactions between services. Key insights and best practices include:

*   **Principle of Least Privilege:** Grant only the permissions required to perform a task. This minimizes the potential impact of compromised credentials.
*   **IAM Roles for Services:** Instead of using IAM users with access keys, assign IAM roles to AWS services (like Lambda functions) to grant them temporary permissions. This is a more secure approach as it eliminates the need to manage long-lived credentials.
*   **Granular Permissions:** Create fine-grained IAM policies that specify the exact actions allowed on specific resources. For example, a Lambda function should only have `dynamodb:PutItem` and `dynamodb:GetItem` permissions on a particular DynamoDB table, not full access to all DynamoDB tables.
*   **Managed Policies vs. Inline Policies:** Use AWS managed policies for common use cases, but create custom inline policies for specific, granular permissions tailored to your application's needs.
*   **Resource-Based Policies:** Some AWS services (like S3 and SQS) support resource-based policies, which allow you to grant permissions directly on the resource itself. This can complement identity-based policies.

## Project Folder Structure

As outlined in the main study plan, this project will reside within the `AWSCloud` master folder with a specific structure to organize infrastructure code, application code, and GitHub Actions workflows.

```
AWSCloud/
├── 01-serverless-web-app/
│   ├── infra/                  # Terraform code for AWS infrastructure
│   │   ├── main.tf             # Main Terraform configuration
│   │   ├── variables.tf        # Input variables for Terraform
│   │   ├── outputs.tf          # Output values from Terraform
│   │   └── versions.tf         # Terraform and provider version constraints
│   ├── app/                    # Application code (e.g., Lambda function code, static website files)
│   │   ├── lambda_function/    # Python code for Lambda function
│   │   │   └── main.py
│   │   │   └── requirements.txt
│   │   ├── website/            # Static website files
│   │   │   ├── index.html
│   │   │   └── style.css
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

This workflow will manage the AWS infrastructure defined in the `infra/` directory using Terraform. It will consist of five manually triggered jobs:

*   **`init`**: Initializes the Terraform working directory. This step is crucial for setting up the backend and downloading necessary provider plugins.
    ```yaml
    name: Terraform Infra Pipeline

on: workflow_dispatch

jobs:
  init:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1 # Or your preferred region

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.x.x # Specify your desired Terraform version

      - name: Terraform Init
        run: terraform init
        working-directory: ./AWSCloud/01-serverless-web-app/infra
    ```

*   **`validate`**: Validates the Terraform configuration files for syntax and consistency. This job helps catch errors early in the development cycle.
    ```yaml
    # ... (previous jobs)

  validate:
    runs-on: ubuntu-latest
    needs: init # Ensures init runs before validate
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.x.x

      - name: Terraform Init (re-run for validate job)
        run: terraform init
        working-directory: ./AWSCloud/01-serverless-web-app/infra

      - name: Terraform Validate
        run: terraform validate
        working-directory: ./AWSCloud/01-serverless-web-app/infra
    ```

*   **`plan`**: Generates and displays an execution plan, showing what actions Terraform will take. This is a critical review step before applying changes.
    ```yaml
    # ... (previous jobs)

  plan:
    runs-on: ubuntu-latest
    needs: validate # Ensures validate runs before plan
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.x.x

      - name: Terraform Init (re-run for plan job)
        run: terraform init
        working-directory: ./AWSCloud/01-serverless-web-app/infra

      - name: Terraform Plan
        run: terraform plan -out=tfplan
        working-directory: ./AWSCloud/01-serverless-web-app/infra

      - name: Upload Terraform Plan Artifact
        uses: actions/upload-artifact@v3
        with:
          name: tfplan
          path: ./AWSCloud/01-serverless-web-app/infra/tfplan
    ```

*   **`apply`**: Applies the changes defined in the Terraform plan to provision or update AWS resources. This job will depend on the `plan` job and will require manual approval for execution.
    ```yaml
    # ... (previous jobs)

  apply:
    runs-on: ubuntu-latest
    needs: plan # Ensures plan runs before apply
    environment:
      name: production # Requires manual approval for production deployments
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.x.x

      - name: Download Terraform Plan Artifact
        uses: actions/download-artifact@v3
        with:
          name: tfplan
          path: ./AWSCloud/01-serverless-web-app/infra

      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan
        working-directory: ./AWSCloud/01-serverless-web-app/infra
    ```

*   **`destroy`**: Destroys the AWS infrastructure managed by Terraform. This job will also require manual approval to prevent accidental resource deletion.
    ```yaml
    # ... (previous jobs)

  destroy:
    runs-on: ubuntu-latest
    environment:
      name: production # Requires manual approval for destroying production resources
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.x.x

      - name: Terraform Init (re-run for destroy job)
        run: terraform init
        working-directory: ./AWSCloud/01-serverless-web-app/infra

      - name: Terraform Destroy
        run: terraform destroy -auto-approve
        working-directory: ./AWSCloud/01-serverless-web-app/infra
    ```

### `app-pipeline.yml` (Application CI/CD)

This workflow will handle the deployment of the application code (Lambda function and static website) to AWS. It will be triggered on pushes to the `main` branch.

```yaml
name: Application CI/CD Pipeline

on:
  push:
    branches:
      - main
    paths:
      - 'AWSCloud/01-serverless-web-app/app/**'

jobs:
  deploy-lambda:
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

      - name: Install dependencies
        run: pip install -r ./AWSCloud/01-serverless-web-app/app/lambda_function/requirements.txt -t ./package
        working-directory: ./AWSCloud/01-serverless-web-app/app/lambda_function

      - name: Zip Lambda function code
        run: |
          cd ./AWSCloud/01-serverless-web-app/app/lambda_function/package
          zip -r9 ../function.zip .
          cd ../
          zip -g function.zip main.py

      - name: Deploy Lambda function
        run: aws lambda update-function-code --function-name YOUR_LAMBDA_FUNCTION_NAME --zip-file fileb://function.zip
        working-directory: ./AWSCloud/01-serverless-web-app/app/lambda_function

  deploy-website:
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

      - name: Sync S3 bucket
        run: aws s3 sync ./AWSCloud/01-serverless-web-app/app/website/ s3://YOUR_S3_BUCKET_NAME --delete
```

**Note:** Replace `YOUR_LAMBDA_FUNCTION_NAME` and `YOUR_S3_BUCKET_NAME` with your actual Lambda function name and S3 bucket name after infrastructure provisioning. The Terraform code will output these values.

This concludes the detailed design and documentation for Project 01. The next step will be to develop the actual Terraform and application code based on this design.

