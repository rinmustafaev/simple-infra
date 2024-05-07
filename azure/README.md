# Terraform AWS Infrastructure

This repository hosts Terraform scripts designed to provision Azure infrastructure resources.

## Prerequisites

Before utilizing these Terraform scripts, ensure the following prerequisites are satisfied:

- **Terraform**: Terraform must be installed on your machine. Follow the installation instructions provided [here](https://learn.hashicorp.com/tutorials/terraform/install-cli) to install Terraform.

## Usage

To utilize these Terraform scripts, adhere to the following steps:

1. Clone this repository onto your local machine.
2. Navigate to the `azure` directory within the cloned repository.
3. Initialize the Terraform working directory by executing the following command: `terraform init`
4. Verify the execution plan with: `terraform plan -out=plan`
5. Apply the changes with: `terraform apply "plan"`


## Infrastructure Details

The Terraform scripts in this repository provision the following resources within your Azure account in the `West Europe` region:

1. **Virtual Network (VN)**: A Virtual Network with private and public subnets. The configuration for this resource is defined in `main.tf`.
2. **Virtual Machines**: Two virtual machines are deployed in the private subnet without having public IPs attached directly. The configuration for this resource is defined in `vms.tf`.
3. **Load Balancer**: A load balancer is provided to access one machine (vm1) and also serves as an outbound gateway (SNAT) for both virtual machines. Load balancing rules are used for this purpose, but the same can also be achieved via LB inbound rules. The configuration for this resource is defined in `public_endpoint.tf`.

