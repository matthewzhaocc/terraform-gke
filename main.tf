// pull in GCP tf provider
provider "google" {
  project = var.project
  region  = var.region
}

// generate cluster name
resource "random_string" "cluster_name" {
  length  = 12
  special = false
  upper   = false
}

// spawn in the cluster
resource "google_container_cluster" "compute" {
  name     = random_string.cluster_name.result
  location = var.region

  // initialize nodepool but remove it once done using it
  remove_default_node_pool = true
  initial_node_count       = 1
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

// create the resource pool for running pods
resource "google_container_node_pool" "compute_node_pool" {
  name       = "compute-nodepool"
  location   = "us-west1"
  cluster    = google_container_cluster.compute.name
  node_count = 2

  // configure the nodes
  node_config {
    // I am too cheap
    preemptible  = true
    machine_type = var.node_type
    // metadata to disable legacy endpoints
    metadata = {
      disable-legacy-endpoints = "true"
    }

    // oauth scopez
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

}
