variable "project_id" {
  description = "The ID of the project where the resources will be created"
  type = string
}

variable "region" {
  description = "The region where the resources will be created"
  default     = "us-central1"
  type = string
}

variable "cloud_run_service_name" {
  description = "The name of the Cloud Run service"
  type = string
}

variable "domain" {
  description = "The domain for the SSL certificate"
  type = string
}

variable "vpc_name" {
  description = "The name of the VPC network"
  default     = "custom-vpc"
  type = string
}

variable "subnet_name" {
  description = "The name of the subnet"
  default     = "custom-subnet"
  type = string
}

variable "subnet_ip" {
  description = "The IP range of the subnet"
  default     = "10.0.0.0/16"
  type = string
}
