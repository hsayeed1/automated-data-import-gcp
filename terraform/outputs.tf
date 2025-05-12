output "dataset_id" {
  value = google_bigquery_dataset.customer_data_dataset.dataset_id
}

output "table_id" {
  value = google_bigquery_table.customer_table.table_id
}