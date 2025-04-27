# outputs.tf

output "data_lake_bucket_name" {
  value       = google_storage_bucket.data_lake_bucket.name
  description = "The name of the GCS bucket used for the data lake"
}

output "bigquery_dataset_name" {
  value       = google_bigquery_dataset.dataset.dataset_id
  description = "The name of the BigQuery dataset"
}

output "airflow_instance_name" {
  value       = google_compute_instance.airflow_instance.name
  description = "The name of the Compute Engine instance for Airflow"
}

output "airflow_instance_external_ip" {
  value       = google_compute_instance.airflow_instance.network_interface[0].access_config[0].nat_ip
  description = "The external IP of the Airflow instance"
}