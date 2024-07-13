# Myloadbalancer
# Setting Up a Regional External Load Balancer on Google Cloud Platform (GCP) with Terraform

This guide walks you through the process of setting up a regional external load balancer on GCP using Terraform. The load balancer will route traffic to a Cloud Run service, providing scalable and reliable HTTP(S) load balancing.

## Prerequisites

Before you begin, ensure you have the following:
- A Google Cloud Platform (GCP) account.
- `gcloud` CLI installed and configured.
- Terraform installed on your local machine.
- A GCP project with billing enabled.
- A service account with the necessary permissions to manage GCP resources.

## Step-by-Step Guide

### Step 1: Configure Terraform Provider

Set up the Terraform provider for Google Cloud:

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}
### Define the necessary variables in a `variables.tf` file:

```hcl
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "" Your intended region
}

variable "cloud_run_service_name" {
  description = "The name of the Cloud Run service"
  type        = string
}
Step 3: Create Network and Subnet
Create a VPC network and a subnetwork in your network.tf file:

hcl
Copy code
resource "google_compute_network" "vpc_network" {
  name                    = "" Intended name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = ""
  ip_cidr_range = ""
  region        = var.region
  network       = google_compute_network.vpc_network.self_link
}
Step 4: Create Cloud Run Service
Deploy a Cloud Run service in your main.tf file (assuming you have a Docker image):

hcl
Copy code
resource "google_cloud_run_service" "service" {
  name     = var.cloud_run_service_name
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/your-image"
      }
    }
  }
}
Step 5: Create Backend Service
Create a regional backend service that points to the Cloud Run service in your main.tf file:

hcl
Copy code
resource "google_compute_region_backend_service" "default" {
  name                  = "${var.cloud_run_service_name}-backend"
  region                = var.region
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  
  backend {
    group = google_compute_region_network_endpoint_group.default.id
  }
}
Step 6: Create URL Map
Create a URL map to route requests to the backend service in your main.tf file:

Step 7: Create HTTPS Proxy
Create a regional HTTPS proxy to route requests through HTTPS in your main.tf file:

hcl

Step 8: Create Forwarding Rule
Create a regional forwarding rule to route incoming traffic to the HTTPS proxy in your main.tf file:


Step 9: Configure SSL Certificate
Configure an SSL certificate to secure the load balancer in your main.tf file:

hcl
Copy code

Step 10: Configure Firewall Rules
Create firewall rules to allow HTTP and HTTPS traffic in your main.tf file:

hcl
Conculsion
By following the steps outlined above, you have successfully created a regional external load balancer on Google Cloud Platform using Terraform. The load balancer routes traffic to a Cloud Run service, secured with an SSL certificate, ensuring secure and efficient handling of HTTP(S) traffic.
KEEP IN MIND THAT THIS REGIONAL SO ALL RESOURCES MUST BE REGIONAL 
EDIT THIS TO FIT YOUR PROJECT