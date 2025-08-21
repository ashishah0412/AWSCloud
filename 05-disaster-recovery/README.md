# Project 05: Disaster Recovery with Cross-Region Replication and Route 53 Failover

## Overview

This project focuses on designing and implementing a robust disaster recovery (DR) strategy for a critical application using AWS services. The core of this strategy involves cross-region replication for data storage (Amazon S3 and Amazon RDS) and intelligent traffic routing with Amazon Route 53 DNS failover. This setup aims to minimize downtime (Recovery Time Objective - RTO) and data loss (Recovery Point Objective - RPO) in the event of a regional outage, ensuring business continuity.

## Architecture

Disaster recovery involves replicating critical application components and data to a secondary, geographically separate AWS region. The architecture for this project will demonstrate a multi-region active-passive (pilot light or warm standby) DR pattern. The key components and their interactions are as follows:

1.  **Primary AWS Region:** Hosts the fully operational application stack, including EC2 instances, RDS databases, and S3 buckets.

2.  **Secondary AWS Region:** Hosts a minimal or scaled-down replica of the application infrastructure, ready to be scaled up or activated in a disaster scenario. This includes replicated data and pre-configured infrastructure.

3.  **Amazon S3 Cross-Region Replication (CRR):** Automatically replicates objects from a source S3 bucket in the primary region to a destination S3 bucket in the secondary region. This ensures that critical application data stored in S3 is continuously backed up and available in the DR region.

4.  **Amazon RDS Cross-Region Read Replicas / Snapshots:** For relational databases, cross-region read replicas provide a near real-time copy of your database in the secondary region, significantly reducing RPO. Alternatively, automated snapshots can be copied across regions.

5.  **Amazon EC2 AMIs / Launch Templates:** Application servers (EC2 instances) in the secondary region can be launched from pre-configured Amazon Machine Images (AMIs) or defined via Launch Templates, ensuring consistent and rapid deployment during a failover.

6.  **Amazon Route 53 DNS Failover:** Route 53 health checks continuously monitor the health of the application endpoints in the primary region. In case of an outage, Route 53 automatically updates DNS records to direct traffic to the secondary region, initiating the failover process.

7.  **AWS Systems Manager (SSM):** Can be used to automate the recovery process in the secondary region, such as launching EC2 instances from AMIs, updating configurations, or performing post-failover tasks.

### Data Flow (Failover Scenario):

*   Route 53 health checks detect an outage in the primary region.
*   Route 53 automatically updates the DNS record for the application to point to the ALB/endpoint in the secondary region.
*   New user requests are directed to the secondary region.
*   In the secondary region, the pre-provisioned (pilot light) or newly launched (warm standby) application instances connect to the replicated RDS database and access replicated S3 data.
*   The application resumes operation in the secondary region.

## AWS Services Deep Dive and Insights

### Disaster Recovery Strategies and Metrics

Understanding DR strategies and key metrics is fundamental:

*   **Recovery Time Objective (RTO):** The maximum acceptable delay between the interruption of service and restoration of service. This dictates how quickly your application must be available after a disaster.
*   **Recovery Point Objective (RPO):** The maximum acceptable amount of data loss measured in time. This dictates how much data you can afford to lose during a disaster.

AWS offers several DR patterns, each with different RTO/RPO characteristics and costs:

*   **Backup and Restore:** Highest RTO/RPO, lowest cost. Data is backed up and restored in a new region.
*   **Pilot Light:** Lower RTO/RPO, moderate cost. A minimal set of core resources are kept running in the DR region, ready to be scaled up.
*   **Warm Standby:** Even lower RTO/RPO, higher cost. A scaled-down but fully functional version of the application is running in the DR region.
*   **Multi-Site Active/Active:** Lowest RTO/RPO, highest cost. The application runs simultaneously in multiple regions.

This project will primarily focus on a **Pilot Light** or **Warm Standby** approach, leveraging cross-region data replication.

### Amazon S3 Cross-Region Replication (CRR)

CRR is a bucket-level configuration that enables automatic, asynchronous copying of objects across buckets in different AWS Regions. Key insights:

*   **Versioning Requirement:** Both source and destination buckets must have versioning enabled.
*   **IAM Permissions:** The IAM role used for replication must have permissions to read from the source bucket and write to the destination bucket.
*   **Replication Configuration:** You can configure replication for an entire bucket, or for objects with a specific prefix or tags.
*   **Replication Time Control (RTC):** Provides an SLA for replicating most objects within 15 minutes, useful for meeting stricter RPO requirements.
*   **Eventual Consistency:** CRR is eventually consistent, meaning it might take some time for objects to appear in the destination bucket.

### Amazon RDS Cross-Region Read Replicas

For supported database engines, RDS allows you to create read replicas in a different AWS region from the source DB instance. Key insights:

*   **Asynchronous Replication:** Data is asynchronously replicated from the primary DB instance to the read replica.
*   **Promotion to Primary:** In a DR scenario, a cross-region read replica can be promoted to a standalone primary DB instance, significantly reducing recovery time.
*   **Monitoring Replication Lag:** It's crucial to monitor the replication lag to understand your RPO. CloudWatch metrics provide this information.
*   **Snapshots:** Even if read replicas are not used, automated snapshots of RDS instances can be copied to a different region and restored in a DR scenario.

### Amazon EC2 AMIs and Launch Templates

To quickly provision compute capacity in the DR region:

*   **Custom AMIs:** Create custom AMIs of your application servers in the primary region and copy them to the secondary region. This ensures that instances launched in the DR region have the correct operating system, application code, and configurations.
*   **Launch Templates:** Define the configuration for launching EC2 instances, including AMI ID, instance type, network settings, and user data. These can be used by Auto Scaling Groups in the DR region.

### Amazon Route 53 DNS Failover

Route 53 provides robust DNS failover capabilities to automatically redirect traffic to a healthy endpoint. Key insights:

*   **Health Checks:** Route 53 health checks monitor the health of your application endpoints (e.g., ALB DNS name, IP address). You can configure thresholds for unhealthy checks.
*   **Failover Routing Policy:** Configure a failover routing policy for your domain. This involves a primary record set pointing to your primary region endpoint and a secondary (failover) record set pointing to your DR region endpoint. When the primary endpoint is unhealthy, Route 53 automatically serves the secondary record.
*   **DNS TTL:** The Time-To-Live (TTL) value for your DNS records impacts RTO. A lower TTL means changes propagate faster, but can increase DNS query costs.
*   **Weighted Routing:** Can be used in conjunction with failover for more advanced scenarios, such as gradually shifting traffic or A/B testing.

### AWS Systems Manager (SSM)

SSM can orchestrate the recovery process in the DR region. Key insights:

*   **Automation Documents:** Create SSM Automation documents to define runbooks for DR procedures, such as launching EC2 instances, attaching volumes, or updating application configurations.
*   **Run Command:** Execute commands on EC2 instances to perform post-recovery tasks.
*   **Parameter Store:** Securely store configuration parameters and secrets needed for the DR process.

## Project Folder Structure

```
AWSCloud/
├── 05-disaster-recovery/
│   ├── infra/                  # Terraform code for AWS infrastructure in primary and secondary regions
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── versions.tf
│   │   ├── primary-region.tf   # Resources specific to primary region
│   │   └── secondary-region.tf # Resources specific to secondary region
│   ├── .github/                # GitHub Actions workflows
│   │   ├── workflows/
│   │   │   ├── infra-pipeline.yml    # Workflow for Terraform (Init, Validate, Plan, Apply, Destroy)
│   │   │   └── dr-failover.yml       # Workflow for initiating DR failover
│   ├── README.md               # Project-specific documentation (this file)
│   └── .gitignore              # Git ignore file
```

## GitHub Actions Workflows

This project will utilize GitHub Actions workflows to automate the infrastructure provisioning and the DR failover process.

### `infra-pipeline.yml` (Terraform CI/CD)

This workflow will manage the AWS infrastructure defined in the `infra/` directory using Terraform. It will consist of five manually triggered jobs, similar to previous projects. The Terraform configuration will be designed to deploy resources to both primary and secondary regions.

*   **`init`**: Initializes the Terraform working directory.
*   **`validate`**: Validates the Terraform configuration files.
*   **`plan`**: Generates and displays an execution plan.
*   **`apply`**: Applies the changes defined in the Terraform plan. Requires manual approval.
*   **`destroy`**: Destroys the AWS infrastructure managed by Terraform. Requires manual approval.

*(The content of `infra-pipeline.yml` will be similar to Project 01, with the `working-directory` adjusted to `./AWSCloud/05-disaster-recovery/infra`)*

### `dr-failover.yml` (Disaster Recovery Failover Workflow)

This workflow will be manually triggered to simulate a DR failover. It will update Route 53 records to direct traffic to the secondary region and can optionally trigger SSM Automation documents to scale up resources in the DR region.

```yaml
name: Disaster Recovery Failover

on: workflow_dispatch

jobs:
  initiate-failover:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1 # Primary region

      - name: Update Route 53 DNS for Failover
        run: |
          # Example: Update a Route 53 record to point to the DR region endpoint
          # Replace YOUR_HOSTED_ZONE_ID, YOUR_RECORD_NAME, YOUR_RECORD_TYPE, YOUR_DR_ENDPOINT
          aws route53 change-resource-record-sets \
            --hosted-zone-id YOUR_HOSTED_ZONE_ID \
            --change-batch file://./AWSCloud/05-disaster-recovery/infra/route53-failover-change-batch.json

      - name: Trigger SSM Automation for DR Region (Optional)
        run: |
          # Example: Start EC2 instances or scale up Auto Scaling Group in DR region
          # Replace YOUR_DR_REGION and YOUR_SSM_AUTOMATION_DOCUMENT_NAME
          aws ssm start-automation-execution \
            --document-name YOUR_SSM_AUTOMATION_DOCUMENT_NAME \
            --parameters InstanceIds=i-xxxxxxxxxxxxxxxxx \
            --region us-west-2 # Secondary region
```

**Note:** The `route53-failover-change-batch.json` file would contain the JSON structure for updating Route 53 records. This file would be part of your `infra` directory. You would need to replace placeholders like `YOUR_HOSTED_ZONE_ID`, `YOUR_RECORD_NAME`, `YOUR_RECORD_TYPE`, `YOUR_DR_ENDPOINT`, and `YOUR_SSM_AUTOMATION_DOCUMENT_NAME` with your actual values.

This concludes the detailed design and documentation for Project 05. The next step will be to develop the actual Terraform code based on this design.

