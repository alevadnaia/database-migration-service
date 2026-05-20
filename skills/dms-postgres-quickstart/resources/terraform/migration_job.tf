resource "google_database_migration_service_migration_job" "psql_to_psql" {
  project               = var.project_id
  location              = var.region
  migration_job_id      = "mj-pg-quickstart-${var.suffix}"
  display_name          = "mj-pg-quickstart-${var.suffix}"

  source      = google_database_migration_service_connection_profile.source_pg.name
  destination = google_database_migration_service_connection_profile.dest_pg.name
  type        = "CONTINUOUS"

  postgres_homogeneous_config {
    is_native_logical            = true
    max_additional_subscriptions = 10
  }

  # Initially set to "NOT_STARTED". When ready to verify and execute:
  # set state to "RUNNING" and stop_on_warnings = true.
  state            = "RUNNING"
  stop_on_warnings = true

  objects_config {
    source_objects_config {
      objects_selection_type = "SPECIFIED_OBJECTS"
      object_configs {
        object_identifier {
          type     = "DATABASE"
          database = "postgres"
        }
      }
    }
  }
}
