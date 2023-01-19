# Core Production Infrastructure on AWS with Terraform

This repo sets up an infrastructure AWS, using [HashiCorp Terraform](), consisting of various server groups, a load balancer, a virtual private network, and all other connecting pieces to simulate a "production like" environment.  Additionally, this infrastructure includes [HashiCorp Boundary]() in order to securely connect to the servers within the network.

## Getting Started

### Prerequisites

1. Have an [AWS Account](https://aws.amazon.com/).

2. Install [HashiCorp Terraform](https://www.terraform.io/downloads).

3. Have the [AWS CLI Installed](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

4. Create an [AWS IAM User](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html) with Admin or Power User Permissions.
  - this user will only be used locally

5. [Configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) with the IAM User from Step 4.
  - Terraform will read your credentials via the AWS CLI Profile
  - [Other Authentication Methods with AWS and Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication)

6. Create an [EC2 Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) so that you can access your public servers.
  - This is for debugging.  Best practice would be to set up a bastion (aka jump box) and only allow SSH access onto your public / private servers from that.

<!-- Insert Boundary Instructions -->

### Using this Code Locally

1. Clone this repo to an empty directory.

2. Run `terraform init` to initialize the project and pull down modules.

3. Run `terraform plan` to see what resources will be created.

4. Run `terraform apply` to create the infrastructure on AWS!

5. Navigate to the `service_endpoint` output by Terraform to see the live service.

6. When finished, run `terraform destroy` to destroy the infrastructure.
