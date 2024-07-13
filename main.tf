  resource "google_cloud_run_service" "default" {
    name     = var.cloud_run_service_name
    location = var.region

    template {
      spec {
        containers {
          image = "gcr.io/cloudrun/hello"  # Replace with your container image
        }
      }
    }

    traffic {
      percent         = 100
      latest_revision = true
    }
 }

  resource "google_compute_region_network_endpoint_group" "default" {
    name                  = "${var.cloud_run_service_name}-neg"
    network_endpoint_type = "SERVERLESS"
    region                = var.region

    cloud_run {
      service = google_cloud_run_service.default.name

    }
  }
  

  resource "google_compute_region_backend_service" "default" {
    name                            = "${var.cloud_run_service_name}-backend"
    region                          = var.region
    load_balancing_scheme           = "EXTERNAL_MANAGED"
    protocol                        = "HTTPS"
    connection_draining_timeout_sec = 300
    enable_cdn                      = false
    
    

    backend {
      group          = google_compute_region_network_endpoint_group.default.id
      capacity_scaler = 1.0
      balancing_mode = "UTILIZATION"
    }
  }

  resource "google_compute_region_url_map" "default" {
   name   = "${var.cloud_run_service_name}-url-map"
   region = var.region

   default_service = google_compute_region_backend_service.default.self_link

   host_rule {
     hosts        = ["kuramaru.xyz"]
     path_matcher = "path-matcher"
   }

   path_matcher {
     name            = "path-matcher"
     default_service = google_compute_region_backend_service.default.self_link

     path_rule {
       paths   = ["/service1/*"]
       service = google_compute_region_backend_service.default.self_link
     }

     path_rule {
       paths   = ["/service2/*"]
       service = google_compute_region_backend_service.default.self_link
     }
   }
 }


  resource "google_compute_region_ssl_certificate" "dummy_cert" {
    name        = "${var.cloud_run_service_name}-dummy-cert"
    region      = var.region
    private_key = file("C:/Users/Admin/dummy-key.pem")
    certificate = file("C:/Users/Admin/dummy-cert.pem")
  }


 resource "google_compute_address" "default" {
       name        = "${var.cloud_run_service_name}-ip"
       address_type = "EXTERNAL"
       ip_version  = "IPV4"
       region           = var.region
     }

  

     resource "google_compute_region_target_https_proxy" "default" {
      name             = "${var.cloud_run_service_name}-https-proxy"
      url_map          = google_compute_region_url_map.default.self_link
      ssl_certificates = [google_compute_region_ssl_certificate.dummy_cert.self_link]
      region           = var.region

       depends_on = [google_compute_region_ssl_certificate.dummy_cert]
    }



       resource "google_compute_forwarding_rule" "https" {
     name                  = "${var.cloud_run_service_name}-https-forwarding-rule"
     load_balancing_scheme = "EXTERNAL_MANAGED"
     target                = google_compute_region_target_https_proxy.default.self_link
     port_range            = "443"
     region                = var.region
     ip_address            = google_compute_address.default.address
     project               = var.project_id
     network_tier          = "PREMIUM"
     network               = google_compute_network.vpc_network.self_link

   }
     


  resource "google_compute_network" "vpc" {
    name = "${var.cloud_run_service_name}-vpc"
  }

 resource "google_compute_subnetwork" "proxy_only_subnet" {
  name          = "proxy-only-subnet"
  ip_cidr_range = "10.2.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.self_link
  purpose       = "REGIONAL_MANAGED_PROXY"  
  role          = "ACTIVE"
}
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-v2"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
  target_tags   = ["http-server"]
  priority      = 1000
  description   = "Allow incoming HTTP traffic"
}

resource "google_compute_firewall" "allow_https" {
  name    = "allow-https-v2"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
  target_tags   = ["https-server"]
  priority      = 1000
  description   = "Allow incoming HTTPS traffic"
}

resource "google_compute_health_check" "default" {
  name     = "${var.cloud_run_service_name}-health-check"
  

  http_health_check {
    request_path = "/"
    port         = "433"
  }
}
 
