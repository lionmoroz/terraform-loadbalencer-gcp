# terraform-loadbalencer-gcp

Terraform GCP Load Balancer

This Terraform project creates a Google Cloud Platform (GCP) Load Balancer with HTTP(s) backend services. The project includes the configuration for a global load balancer and a backend service running on multiple instances.


Prerequisites
Before you can use this project, you will need to have the following:

- A GCP account with billing enabled
- The Terraform CLI installed on your local machine
- A GCP project where you want to create the Load Balancer
- One or more backend instances that you want to distribute traffic to


Usage
- Clone the repository to your local machine using the following command: 
git clone https://github.com/your-username/terraform-loadbalencer-gcp.git

- Change into the project directory:
cd terraform-loadbalencer-gcp

- Initialize the Terraform project by running:
terraform init

- Modify the variables.tf file to specify the name, port, and protocol for your Load Balancer. You can also modify the backend.tf file to specify the backend instances that you want to distribute traffic to.

- Run "terraform plan" to preview the changes that will be made.

- If the plan looks good, apply the changes by running:
terraform apply

Contributing
Contributions are welcome! If you would like to contribute to this project, please fork the repository and submit a pull request.