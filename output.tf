    output "cloud_run_url" {
      value = google_cloud_run_service.default.status[0].url
    }

      output "load_balancer_ip" {
         value = google_compute_address.default.address
       }

   output "vpc_network_name" {
     value = google_compute_network.vpc_network.name
   }

   output "subnet_name" {
     value = google_compute_subnetwork.subnetwork.name
   }

   output "subnet_ip" {
     value = google_compute_subnetwork.subnetwork.ip_cidr_range
  }