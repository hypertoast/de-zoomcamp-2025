# variables.tf

variable "project_id" {
  description = "Your GCP Project ID"
  type        = string
}

variable "region" {
  description = "Region for GCP resources"
  type        = string
  default     = "us-central1"
}

variable "data_lake_bucket" {
  description = "Name of the GCS bucket for the data lake"
  type        = string
  default     = "weather_data_lake"
}