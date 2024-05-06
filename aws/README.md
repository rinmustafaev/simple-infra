# Terraform AWS Infrastructure

This repository hosts Terraform scripts designed to provision AWS infrastructure resources.

## Prerequisites

Before utilizing these Terraform scripts, ensure the following prerequisites are satisfied:

- **Terraform**: Terraform must be installed on your machine. Follow the installation instructions provided [here](https://learn.hashicorp.com/tutorials/terraform/install-cli) to install Terraform.

## Usage

To utilize these Terraform scripts, adhere to the following steps:

1. Clone this repository onto your local machine.
2. Navigate to the `aws` directory within the cloned repository.
3. Initialize the Terraform working directory by executing the following command: `terraform init`
4. Verify the execution plan with: `terraform plan -out=plan`
5. Apply the changes with: `terraform apply "plan"`

## Infrastructure Details

The Terraform scripts in this repository provision the following resources within your AWS account in the `eu-west-1` region:

1. **VPC**: A Virtual Private Cloud (VPC) with private and public subnets and a NAT gateway. The configuration for this resource is defined in `main.tf`.
2. **EC2 Instance (External)**: An EC2 instance (`ec2_instance_external`) hosted within the public subnet, running Amazon Linux. This instance exposes port 443. Given the assumption that this instance runs a web server with HTTPS, implementing an application load balancer(443 with TLS on LB) with WAF enabled is not possible, and a network load balancer(443 port forwarding on 4th layer) would be unnecessary overhead for a single machine.
3. **EC2 Instance (Internal)**: A second EC2 instance (`ec2_instance_internal`) that can communicate bidirectionally with the first instance over port 443. Egress traffic for both machines is restricted to within the VPC.