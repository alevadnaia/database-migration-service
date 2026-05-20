resource "google_database_migration_service_private_connection" "default" {
  project               = var.project_id
  location              = var.region
  private_connection_id = "pc-${var.suffix}"
  display_name          = "pc-${var.suffix}"

  psc_interface_config {
    network_attachment = var.network_attachment_uri
  }
}
