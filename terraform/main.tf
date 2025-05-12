provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_bigquery_dataset" "customer_data_dataset" {
  dataset_id = "customers_data"
  location   = var.region
}

resource "google_bigquery_table" "customer_table" {
  dataset_id = google_bigquery_dataset.customer_data_dataset.dataset_id
  table_id   = "customer_info"
  deletion_protection = false

  schema = file("${path.module}/schemas/customer_schema.json")
}

# Create a Service Account for the data pipeline
resource "google_service_account" "data_pipeline_sa" {
  account_id   = "data-pipeline-sa"
  display_name = "Data Pipeline Service Account"
  project      = var.project_id
}

# Assign BigQuery Admin role to the service account
resource "google_project_iam_member" "bigquery_admin" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:${google_service_account.data_pipeline_sa.email}"
}

# Assign Storage Admin role to the service account (for GCS access)
resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.data_pipeline_sa.email}"
}

# Generate the service account key
resource "google_service_account_key" "data_pipeline_sa_key" {
  service_account_id = google_service_account.data_pipeline_sa.name
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}


# Output the service account key for manual download
output "service_account_key" {
  value = google_service_account_key.data_pipeline_sa_key.private_key
  sensitive = true
}

