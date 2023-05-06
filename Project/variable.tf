variable "region" {
  type        = string
  description = "Enter region"
  default     = "us-east-1"
}

variable "vpc_name" {
  default = ""
}

variable "igw_name" {
  default = ""
}

variable "public_cidr_block" {
  default     = ""
}

variable "public_subnet_name" {
  default     = ""
}

variable "private_cidr_block" {
  default     = ""
}

variable "private_subnet_name" {
  default     = ""
}

variable "availability_zone_web" {
  default     = ""
}

variable "availability_zone_mysql" {
  default     = ""
}

variable "az1" {
  default     = ""
}

variable "az2" {
  default     = ""
}