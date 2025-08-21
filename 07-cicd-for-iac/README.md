# Project 07: CI/CD for Infrastructure as Code with Terraform and GitHub Actions

## Overview

This project is a meta-project, focusing purely on the Continuous Integration/Continuous Delivery (CI/CD) pipeline for Infrastructure as Code (IaC) using Terraform and GitHub Actions. It demonstrates how to automate the `terraform init`, `validate`, `plan`, `apply`, and `destroy` operations for a simple AWS resource. This project is fundamental as it establishes the best practices for managing infrastructure changes in a controlled, automated, and auditable manner, which is critical for both the Solutions Architect Professional and DevOps Engineer Professional certifications.

## Architecture

The architecture for this project is centered around the CI/CD pipeline itself, with minimal AWS resources to demonstrate the IaC workflow. The key components and their interactions are as follows:

1.  **Terraform:** The IaC tool used to define and provision the AWS infrastructure. In this project, it will manage a simple S3 bucket.

2.  **Amazon S3 (for Terraform Backend):** A dedicated S3 bucket will be used to store the Terraform state file. Storing the state remotely in S3 enables collaboration among team members and provides state locking to prevent concurrent modifications.

3.  **Amazon DynamoDB (for Terraform State Locking):** A DynamoDB table will be used to implement state locking for the Terraform backend. This prevents multiple users from concurrently running Terraform commands against the same state file, which could lead to corruption.

4.  **GitHub Repository:** Hosts the Terraform code and the GitHub Actions workflow definitions.

5.  **GitHub Actions:** The CI/CD platform that automates the execution of Terraform commands. It will be configured with distinct jobs for `init`, `validate`, `plan`, `apply`, and `destroy`, with `apply` and `destroy` requiring manual approval for safety.

6.  **AWS Identity and Access Management (IAM):** IAM roles and policies will be used to grant GitHub Actions the necessary permissions to interact with AWS services (S3, DynamoDB, and the resource being managed by Terraform).

### Data Flow:

*   A developer pushes changes to the Terraform code in the GitHub repository.
*   A GitHub Actions workflow is manually triggered (or on pull request).
*   The workflow executes Terraform commands (`init`, `validate`, `plan`, `apply`, `destroy`) in a controlled environment.
*   Terraform interacts with AWS to manage the infrastructure, storing its state in the S3 backend and using DynamoDB for state locking.
*   The results of the Terraform operations are reported back in the GitHub Actions workflow logs.

## AWS Services Deep Dive and Insights

### Terraform State Management

Managing Terraform state is crucial for collaborative environments and maintaining consistency. Key insights:

*   **Remote Backend (S3):** Storing the Terraform state file (`terraform.tfstate`) in an S3 bucket provides a shared, durable, and versioned location for the state. This is essential for teams working on the same infrastructure.
*   **State Locking (DynamoDB):** DynamoDB is used to prevent concurrent modifications to the Terraform state file. When a Terraform operation starts, it acquires a lock in the DynamoDB table. If another operation tries to run concurrently, it will wait until the lock is released. This prevents state corruption.
*   **State File Contents:** The state file maps real-world resources to your configuration, tracks metadata, and caches attribute values. It contains sensitive information, so it should be stored securely and never committed to version control directly.

### GitHub Actions for IaC

GitHub Actions provides a flexible and powerful platform for automating IaC workflows. Key insights:

*   **`workflow_dispatch` Trigger:** Allows manual triggering of workflows, which is ideal for `apply` and `destroy` operations that require explicit human intervention.
*   **`pull_request` Trigger:** Can be used to automatically run `init`, `validate`, and `plan` when a pull request is opened, providing early feedback on infrastructure changes.
*   **`hashicorp/setup-terraform` Action:** A convenient GitHub Action that sets up Terraform CLI in the workflow environment.
*   **`aws-actions/configure-aws-credentials` Action:** Securely configures AWS credentials for the workflow, allowing Terraform to authenticate with AWS.
*   **Environment Protection Rules:** GitHub Environments can be used to enforce manual approvals for sensitive operations like `apply` and `destroy` on production environments, adding a layer of safety.
*   **Artifacts:** Uploading Terraform plan files as artifacts allows for review of proposed changes before applying them.

### AWS IAM for GitHub Actions

Proper IAM configuration is vital for secure CI/CD. Key insights:

*   **Least Privilege:** The IAM user or role used by GitHub Actions should only have the minimum necessary permissions to perform the Terraform operations. For example, if the project only creates an S3 bucket, the IAM policy should only grant S3 permissions.
*   **OpenID Connect (OIDC):** For enhanced security, consider using GitHub Actions' OIDC provider to assume an IAM role, eliminating the need to store long-lived AWS access keys as GitHub secrets. This is a more advanced but highly recommended best practice for production environments.

## Project Folder Structure

```
AWSCloud/
├── 07-cicd-for-iac/
│   ├── infra/                  # Terraform code for AWS infrastructure
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── versions.tf
│   │   └── backend.tf          # Backend configuration for S3 and DynamoDB
│   ├── .github/                # GitHub Actions workflows
│   │   ├── workflows/
│   │   │   └── infra-pipeline.yml    # Workflow for Terraform (Init, Validate, Plan, Apply, Destroy)
│   ├── README.md               # Project-specific documentation (this file)
│   └── .gitignore              # Git ignore file
```

## GitHub Actions Workflows

This project will primarily utilize a single GitHub Actions workflow to automate the infrastructure provisioning.

### `infra-pipeline.yml` (Terraform CI/CD)

This workflow will manage the AWS infrastructure defined in the `infra/` directory using Terraform. It will consist of five manually triggered jobs:

*   **`init`**: Initializes the Terraform working directory.
*   **`validate`**: Validates the Terraform configuration files.
*   **`plan`**: Generates and displays an execution plan.
*   **`apply`**: Applies the changes defined in the Terraform plan. Requires manual approval.
*   **`destroy`**: Destroys the AWS infrastructure managed by Terraform. Requires manual approval.

```yaml
name: Terraform IaC CI/CD Pipeline

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
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.x.x

      - name: Terraform Init
        run: terraform init
        working-directory: ./AWSCloud/07-cicd-for-iac/infra

  validate:
    runs-on: ubuntu-latest
    needs: init
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
        working-directory: ./AWSCloud/07-cicd-for-iac/infra

      - name: Terraform Validate
        run: terraform validate
        working-directory: ./AWSCloud/07-cicd-for-iac/infra

  plan:
    runs-on: ubuntu-latest
    needs: validate
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
        working-directory: ./AWSCloud/07-cicd-for-iac/infra

      - name: Terraform Plan
        run: terraform plan -out=tfplan
        working-directory: ./AWSCloud/07-cicd-for-iac/infra

      - name: Upload Terraform Plan Artifact
        uses: actions/upload-artifact@v3
        with:
          name: tfplan
          path: ./AWSCloud/07-cicd-for-iac/infra/tfplan

  apply:
    runs-on: ubuntu-latest
    needs: plan
    environment:
      name: production
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
          path: ./AWSCloud/07-cicd-for-iac/infra

      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan
        working-directory: ./AWSCloud/07-cicd-for-iac/infra

  destroy:
    runs-on: ubuntu-latest
    environment:
      name: production
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
        working-directory: ./AWSCloud/07-cicd-for-iac/infra

      - name: Terraform Destroy
        run: terraform destroy -auto-approve
        working-directory: ./AWSCloud/07-cicd-for-iac/infra
```

**Note:** This project is infrastructure-focused and does not involve application code deployment, hence no `app-pipeline.yml` is included. The `terraform_version` should be set to a specific version compatible with your environment.

This concludes the detailed design and documentation for Project 07. The next step will be to develop the actual Terraform code based on this design.

