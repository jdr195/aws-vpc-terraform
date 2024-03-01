variable "tags" {
  default = {
    Application = "vpc-terraform"
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR Values"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR Values"
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}
