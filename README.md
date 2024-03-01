# aws-vpc-terraform

Uses [Terraform](https://www.terraform.io/) to reimplement the cloudformation template at [https://docs.aws.amazon.com/codebuild/latest/userguide/cloudformation-vpc-template.html](https://docs.aws.amazon.com/codebuild/latest/userguide/cloudformation-vpc-template.html)

It creates an AWS VPC with an Internet Gateway, 2 public subnets, 2 private subnets, 2 NAT Gateways, and the supporting Routes and Associations.

### Example Usage

```
terraform init
terraform plan
terraform apply

# Cleanup
terraform destroy
```
