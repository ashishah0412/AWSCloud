# AWS Projects

Welcome to your hands-on AWS journey! This repository contains a series of projects designed to help you master AWS services. Each project focuses on practical implementation, infrastructure as code (Terraform), and continuous integration/continuous delivery (CI/CD) with GitHub Actions.

## Initial Setup Instructions

Before you begin working on the projects, you need to perform some initial setup steps in your AWS account and GitHub repository. These steps ensure that you have the necessary permissions and configurations to provision AWS resources and run GitHub Actions workflows.

### 1. AWS Account Setup

To interact with AWS services, you need an AWS account and an IAM user with programmatic access. It is highly recommended to create a dedicated IAM user for these projects with appropriate permissions, rather than using your root account credentials.

**a. Create an IAM User with Programmatic Access:**

1.  Sign in to the AWS Management Console.
2.  Navigate to the IAM dashboard.
3.  In the navigation pane, choose **Users**, and then choose **Add users**.
4.  Enter a user name (e.g., `aws-cert-project-user`).
5.  Select **Programmatic access** as the AWS access type.
6.  Choose **Next: Permissions**.
7.  Attach existing policies directly. For simplicity and to cover all project requirements, you can attach `AdministratorAccess`. **However, for production environments, always adhere to the principle of least privilege and grant only necessary permissions.**
    *   Search for and select `AdministratorAccess`.
8.  Choose **Next: Tags** (optional).
9.  Choose **Next: Review**.
10. Choose **Create user**.
11. **Important:** On the next screen, you will see the **Access key ID** and **Secret access key**. **Download the .csv file or copy these credentials immediately.** You will not be able to retrieve the secret access key again after this step.

**b. Configure AWS CLI (Optional but Recommended):**

While GitHub Actions will use these credentials, having the AWS CLI configured locally can be useful for testing and debugging.

1.  Install the AWS CLI if you haven't already: [https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2.  Configure the AWS CLI with your new IAM user credentials:
    ```bash
    aws configure
    ```
    When prompted, enter your Access Key ID, Secret Access Key, default region (e.g., `us-east-1`), and default output format (e.g., `json`).

### 2. GitHub Repository Setup

Each project in this repository utilizes GitHub Actions for CI/CD. To enable these workflows, you need to create a GitHub repository and configure GitHub Secrets with your AWS credentials.

**a. Create a New GitHub Repository:**

1.  Go to GitHub and create a new repository (e.g., `aws-certification-projects`).
2.  You can initialize it with a README, but it's not strictly necessary as you will be pushing the project files to it.

**b. Configure GitHub Secrets:**

GitHub Actions workflows need access to your AWS credentials to deploy resources. You will store these securely as GitHub Secrets.

1.  In your GitHub repository, navigate to **Settings**.
2.  In the left sidebar, click on **Secrets and variables**, then **Actions**.
3.  Click on **New repository secret**.
4.  Create two new secrets:
    *   **Name:** `AWS_ACCESS_KEY_ID`
        *   **Value:** Your AWS IAM user's Access Key ID.
    *   **Name:** `AWS_SECRET_ACCESS_KEY`
        *   **Value:** Your AWS IAM user's Secret Access Key.

**c. Push Project Files to GitHub:**

After setting up your AWS account and GitHub repository, you can push the `AWSCloud` folder (containing all projects) to your new GitHub repository.

```bash
# Navigate to the root directory containing the AWSCloud folder
cd /path/to/your/AWSCloud/parent/directory

git init
git add AWSCloud/
git commit -m "Initial commit of AWS certification projects"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPOSITORY_NAME.git
git push -u origin main
```

Replace `YOUR_GITHUB_USERNAME` and `YOUR_REPOSITORY_NAME` with your actual GitHub username and repository name.

### 3. Terraform Installation (Local - Optional)

While the GitHub Actions pipelines will handle Terraform execution, you might want to install Terraform locally for development and testing purposes.

1.  Follow the official Terraform installation guide: [https://developer.hashicorp.com/terraform/downloads](https://developer.hashicorp.com/terraform/downloads)

## How to Use the Projects

Each project is self-contained within its `0X-project-name` folder. To work on a specific project:

1.  **Navigate to the Project Directory:**
    ```bash
    cd AWSCloud/01-serverless-web-app
    ```
2.  **Review the `README.md`:** Each project has its own `README.md` file that provides a detailed overview of the project, its architecture, the AWS services involved, and specific instructions.
3.  **Inspect Terraform Code:** The `infra/` directory contains the Terraform configuration files (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`). Review these files to understand the infrastructure being provisioned.
4.  **Inspect Application Code:** The `app/` directory contains the application-specific code (e.g., Lambda function code, static website files).
5.  **Run GitHub Actions Workflows:**
    *   Go to your GitHub repository in the browser.
    *   Navigate to the **Actions** tab.
    *   Select the `Terraform Infra Pipeline` workflow.
    *   Click on **Run workflow** and choose the desired job (`init`, `validate`, `plan`, `apply`, `destroy`). Remember that `apply` and `destroy` jobs require manual approval in the `production` environment (which is the default for these examples).
    *   For application deployments, the `Application CI/CD Pipeline` will trigger automatically on pushes to the `main` branch within the `app/` directory.

**Important:** After provisioning infrastructure with Terraform, remember to update the `YOUR_LAMBDA_FUNCTION_NAME` and `YOUR_S3_BUCKET_NAME` placeholders in the `app-pipeline.yml` with the actual values outputted by Terraform. You can find these outputs in the GitHub Actions `apply` job logs or by running `terraform output` locally after a successful apply.

## Cost Management

To avoid incurring unnecessary AWS costs, it is crucial to destroy the provisioned infrastructure for each project once you are done experimenting with it. Use the `destroy` job in the `Terraform Infra Pipeline` GitHub Actions workflow for this purpose.

By following these instructions, you will be well-equipped to tackle the hands-on projects and gain practical experience with AWS, Terraform, and GitHub Actions, significantly boosting your preparation for the professional-level certifications. Good luck!

