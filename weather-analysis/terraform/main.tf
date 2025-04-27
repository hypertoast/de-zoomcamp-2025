# main.tf

# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a GCS bucket for the data lake
resource "google_storage_bucket" "data_lake_bucket" {
  name     = "${var.project_id}_data_lake"
  location = var.region
  
  # Optional settings
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30  # days
    }
  }
}

# Create BigQuery Dataset
resource "google_bigquery_dataset" "dataset" {
  dataset_id = "weather_data"
  project    = var.project_id
  location   = var.region
  
  delete_contents_on_destroy = true
}

# Set up a Compute Engine instance for Airflow
resource "google_compute_instance" "airflow_instance" {
  name         = "airflow-server"
  machine_type = "e2-standard-4"
  zone         = "${var.region}-a"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 50
    }
  }
  
  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }
  
  metadata_startup_script = file("${path.module}/startup_script.sh")
  
  service_account {
    email  = google_service_account.airflow_service_account.email
    scopes = ["cloud-platform"]
  }
  
  depends_on = [google_service_account.airflow_service_account]
}

# Create a service account for Airflow
resource "google_service_account" "airflow_service_account" {
  account_id   = "airflow-service-account"
  display_name = "Airflow Service Account"
}

# Grant permissions to the service account
resource "google_project_iam_binding" "storage_admin_binding" {
  project = var.project_id
  role    = "roles/storage.admin"
  
  members = [
    "serviceAccount:${google_service_account.airflow_service_account.email}",
  ]
}

resource "google_project_iam_binding" "bigquery_admin_binding" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  
  members = [
    "serviceAccount:${google_service_account.airflow_service_account.email}",
  ]
}