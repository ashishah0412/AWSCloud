# Project 06: Secure Network Design with Transit Gateway and VPN

## Overview

This project focuses on designing and implementing a secure and scalable network architecture in AWS using AWS Transit Gateway to connect multiple Virtual Private Clouds (VPCs) and establish connectivity to an on-premises network via AWS Site-to-Site VPN. This setup provides a centralized hub-and-spoke model for network connectivity, simplifying network management, enhancing security, and enabling efficient routing across a distributed cloud environment.

## Architecture

The secure network design emphasizes centralized network management, simplified routing, and secure connectivity. The core components and their interactions are as follows:

1.  **AWS Transit Gateway (TGW):** A network transit hub that connects your VPCs and on-premises networks. It simplifies your network topology by acting as a central gateway for all network traffic, eliminating the need for complex peering connections between individual VPCs.

2.  **Amazon Virtual Private Cloud (VPC):** Multiple VPCs will be created to represent different environments (e.g., production, development) or different applications. Each VPC will be attached to the Transit Gateway.

3.  **AWS Site-to-Site VPN:** Establishes a secure, encrypted connection between your AWS VPC and your on-premises network. The VPN connection will terminate on the Transit Gateway, allowing on-premises resources to communicate with any VPC connected to the TGW.

4.  **Customer Gateway (CGW):** A resource in AWS that represents your customer gateway device (e.g., router, firewall) in your on-premises network. It provides the necessary information for AWS to establish the VPN connection.

5.  **Transit Gateway Route Tables:** Control how traffic is routed between VPC attachments and VPN connections connected to the Transit Gateway. This allows for granular control over network segmentation and traffic flow.

6.  **Security Groups and Network ACLs:** Used within each VPC to control traffic at the instance and subnet levels, respectively, providing layered security.

7.  **AWS Network Firewall (Conceptual):** While not directly implemented in this project for simplicity, a common best practice is to deploy AWS Network Firewall in a dedicated inspection VPC attached to the Transit Gateway. This allows for centralized traffic inspection and filtering for all traffic flowing through the TGW.

### Data Flow:

*   **VPC-to-VPC Communication:** Traffic between VPCs flows through the Transit Gateway. Each VPC has a route in its route table pointing to the TGW for traffic destined for other connected VPCs.
*   **On-Premises to AWS Communication:** Traffic from the on-premises network travels over the Site-to-Site VPN tunnel to the Transit Gateway. The TGW then routes the traffic to the appropriate VPC based on its route table.
*   **AWS to On-Premises Communication:** Traffic from AWS VPCs destined for the on-premises network is routed to the Transit Gateway, which then forwards it over the VPN tunnel.

## AWS Services Deep Dive and Insights

### AWS Transit Gateway (TGW)

Transit Gateway simplifies network management and provides a highly scalable and resilient way to connect thousands of VPCs and on-premises networks. Key insights:

*   **Hub-and-Spoke Model:** TGW acts as a central hub, and VPCs and VPN connections are spokes. This eliminates the need for a mesh of peering connections, which can become complex and difficult to manage as the number of VPCs grows.
*   **Scalability:** TGW can scale to connect thousands of VPCs and on-premises networks, making it suitable for large and complex organizations.
*   **Centralized Routing:** TGW route tables allow you to define how traffic is routed between attachments. You can associate different route tables with different attachments to implement network segmentation and control traffic flow.
*   **Inter-Region Peering:** Transit Gateway can be peered across regions, enabling global network connectivity and facilitating disaster recovery strategies.
*   **Multicast Support:** TGW supports multicast, which is useful for certain applications like media streaming or financial services.
*   **Shared Services VPC:** A common pattern is to have a shared services VPC (e.g., for Active Directory, monitoring tools) connected to the TGW, allowing all other VPCs to access these centralized services.

### Amazon Virtual Private Cloud (VPC)

VPCs provide a logically isolated section of the AWS Cloud. For this project, multiple VPCs are essential for network segmentation. Key insights:

*   **CIDR Blocks:** Carefully plan your VPC CIDR blocks to avoid overlaps, especially when connecting multiple VPCs via TGW or VPN.
*   **Subnets:** Divide your VPC into subnets (public and private) across multiple Availability Zones for high availability and fault tolerance.
*   **Route Tables:** Each subnet has an associated route table that determines where network traffic is directed. Routes to other VPCs or on-premises networks will point to the Transit Gateway attachment.
*   **Security Groups:** Control inbound and outbound traffic for instances. For example, allowing only specific ports from the TGW attachment.
*   **Network ACLs:** Provide an additional, stateless layer of security at the subnet level.

### AWS Site-to-Site VPN

AWS Site-to-Site VPN creates a secure connection between your on-premises network and your AWS VPCs. Key insights:

*   **Customer Gateway (CGW):** Represents your physical or software appliance on your side of the VPN connection. You provide its public IP address.
*   **Virtual Private Gateway (VGW) or Transit Gateway (TGW):** The AWS side of the VPN connection. For this project, the VPN will terminate on the Transit Gateway.
*   **VPN Tunnels:** AWS provides two VPN tunnels for redundancy and high availability. It's crucial to configure both tunnels on your customer gateway device.
*   **Routing Options:** You can use static routing (manually specify routes) or dynamic routing (BGP - Border Gateway Protocol) to exchange routes between your on-premises network and AWS.
*   **Encryption and Authentication:** VPN connections use IPsec for encryption and authentication, ensuring secure communication.
*   **Monitoring:** Monitor VPN tunnel status and network performance using CloudWatch metrics.

### AWS Network Firewall (Conceptual)

AWS Network Firewall is a managed service that makes it easy to deploy essential network protections for all your Amazon VPCs. Key insights:

*   **Centralized Inspection:** By routing all traffic through a dedicated inspection VPC with Network Firewall, you can centralize traffic inspection and apply consistent security policies across your entire network.
*   **Stateless and Stateful Rules:** Network Firewall supports both stateless (packet filtering) and stateful (connection tracking, protocol inspection) rules.
*   **Threat Signatures:** Integrates with AWS Managed Threat Signatures and allows custom Suricata-compatible rules for advanced threat detection.
*   **Integration with TGW:** Traffic can be routed from TGW to the Network Firewall endpoint in the inspection VPC and then back to the TGW for routing to the destination VPC or on-premises.

### AWS Security Hub (Conceptual)

AWS Security Hub provides a comprehensive view of your security alerts and security posture across your AWS accounts. Key insights:

*   **Centralized Security Findings:** Aggregates security findings from various AWS services (e.g., GuardDuty, Inspector, Macie, IAM Access Analyzer) and partner solutions.
*   **Security Standards:** Automatically checks your AWS environment against security industry standards and best practices (e.g., AWS Foundational Security Best Practices, CIS AWS Foundations Benchmark).
*   **Actionable Insights:** Provides actionable insights and recommendations to improve your security posture.

## Project Folder Structure

```
AWSCloud/
├── 06-secure-network-design/
│   ├── infra/                  # Terraform code for AWS infrastructure
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── .github/                # GitHub Actions workflows
│   │   ├── workflows/
│   │   │   └── infra-pipeline.yml    # Workflow for Terraform (Init, Validate, Plan, Apply, Destroy)
│   ├── README.md               # Project-specific documentation (this file)
│   └── .gitignore              # Git ignore file
```

## GitHub Actions Workflows

This project will primarily utilize a single GitHub Actions workflow to automate the infrastructure provisioning.

### `infra-pipeline.yml` (Terraform CI/CD)

This workflow will manage the AWS infrastructure defined in the `infra/` directory using Terraform. It will consist of five manually triggered jobs, similar to previous projects:

*   **`init`**: Initializes the Terraform working directory.
*   **`validate`**: Validates the Terraform configuration files.
*   **`plan`**: Generates and displays an execution plan.
*   **`apply`**: Applies the changes defined in the Terraform plan. Requires manual approval.
*   **`destroy`**: Destroys the AWS infrastructure managed by Terraform. Requires manual approval.

*(The content of `infra-pipeline.yml` will be similar to Project 01, with the `working-directory` adjusted to `./AWSCloud/06-secure-network-design/infra`)*

**Note:** This project is infrastructure-focused and does not involve application code deployment, hence no `app-pipeline.yml` is included.

This concludes the detailed design and documentation for Project 06. The next step will be to develop the actual Terraform code based on this design.

