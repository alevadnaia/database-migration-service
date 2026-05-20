# Scenario: PostgreSQL Quickstart Migration

This scenario focuses on migrating PostgreSQL databases into Cloud SQL for
PostgreSQL or AlloyDB for PostgreSQL. **Reference Guide**:
[PostgreSQL Quickstart Docs](https://docs.cloud.google.com/database-migration/docs/postgres/quick-start-migrations-guide)

--------------------------------------------------------------------------------

## Configuration Steps

### 1. Identify Destination and Context (Project & Region)

Determine the project and region for the destination instance (either Cloud SQL
for PostgreSQL or AlloyDB for PostgreSQL).

*   If not clear from the user prompt, confirm the destination project and
    region.
*   **Action**: Use this project and region for all allocated resources (Private
    Connections, Connection Profiles, and Migration Jobs).

### 2. Identify Source Configuration

Determine the source configuration setup. Source type can be Self-managed, Cloud
SQL, or AWS RDS Postgres.

*   **Discovery**: Present options from discovered Terraform data, if any.
*   **Fallback**: If Terraform data is unavailable, ask for the **Host**,
    **Port**, **Username**, **Password**, and **VPC** that allows reaching the
    source by the given host and port.
*   **Networking**:
    *   If using a Public IP or a host that resolves to a Public IP, inform the
        user and recommend/deploy a bastion host that forwards traffic to that
        Public IP.

### 3. Connectivity: Private Service Connect Interface

Quickstart migrations **strictly require** Private Service Connect (PSC)
interface connectivity.

*   **Discovery**: Search for existing Private Connections in the destination
    project/region pointing to the source VPC.
*   **Validation**: Must be a PSCI-based connection in the `CREATED` state.
*   **Creation**: If missing, create a new Private Connection. Note that Private
    Connection creation is a long-running operation; wait for it to complete.

**Example for Terraform**:

```hcl
resource "google_database_migration_service_private_connection" "default" {
  project               = var.project_id
  location              = var.region
  private_connection_id = "pc-${var.suffix}"
  display_name          = "pc-${var.suffix}"

  psc_interface_config {
    network_attachment = var.network_attachment_uri
  }
}
```

**Example for gcloud**:

```bash
gcloud database-migration private-connections create ${PRIVATE_CONN} \
  --region=${REGION} \
  --project=${PROJECT_ID} \
  --display-name=${PRIVATE_CONN} \
  --no-async \
  --network-attachment=${NETWORK_ATTACHMENT_URI}
```

### 4. Source Connection Profile

Create and validate the gateway to the source. Note: Always use `template1` as
the database.

**Example for Terraform**:

```hcl
resource "google_database_migration_service_connection_profile" "source_pg" {
  project               = var.project_id
  location              = var.region
  connection_profile_id = "source-pg-cp-${var.suffix}"
  display_name          = "source-pg-cp-${var.suffix}"
  role                  = "SOURCE"

  postgresql {
    host     = var.source_instance_ip
    port     = var.source_port
    username = var.source_user
    password = var.source_password
    database = "template1"

    private_connectivity {
      private_connection = google_database_migration_service_private_connection.default.id
    }

    ssl {
      type = "REQUIRED"
    }
  }
}
```

**Example for gcloud**:

```bash
gcloud database-migration connection-profiles create postgresql \
  ${SOURCE_CONN_ID} \
  --region=${REGION} \
  --project=${PROJECT_ID} \
  --role=SOURCE \
  --host=${SOURCE_INSTANCE_IP} \
  --port=${SOURCE_PORT} \
  --username=${SOURCE_USER} \
  --password=${SOURCE_PASSWORD} \
  --database=template1 \
  --private-connection=${PRIVATE_CONN}
```

If connection profile creation fails or the profile remains in a `FAILED` state,
troubleshoot and resolve errors before proceeding.

### 5. Destination Connection Profile

Create a user on the destination instance for migration purposes using available
tools (rather than direct SQL execution). Ensure the created user has
`cloudsqlsuperuser` (Cloud SQL) or `alloydbsuperuser` (AlloyDB) privileges. Do
not ask the user before creating the user; just create it. Then proceed to
destination connection profile creation.

**Example for Terraform (Cloud SQL Destination)**:

```hcl
resource "google_database_migration_service_connection_profile" "dest_pg" {
  project               = var.project_id
  location              = var.region
  connection_profile_id = "dest-pg-cp-${var.suffix}"
  display_name          = "dest-pg-cp-${var.suffix}"
  role                  = "DESTINATION"

  postgresql {
    username     = var.dms_user
    password     = var.dms_pass
    cloud_sql_id = var.cloud_sql_id
  }
}
```

**Example for Terraform (AlloyDB Destination)**:

```hcl
resource "google_database_migration_service_connection_profile" "dest_pg" {
  project               = var.project_id
  location              = var.region
  connection_profile_id = "dest-pg-cp-${var.suffix}"
  display_name          = "dest-pg-cp-${var.suffix}"
  role                  = "DESTINATION"

  postgresql {
    username        = var.dms_user
    password        = var.dms_pass
    alloydb_cluster_id = var.alloydb_cluster_id
  }
}
```

**Example for gcloud (Cloud SQL Destination)**:

```bash
gcloud database-migration connection-profiles create postgresql \
  ${DEST_CONN_ID} \
  --region=${REGION} \
  --project=${PROJECT_ID} \
  --role=DESTINATION \
  --cloudsql-instance=${CLOUD_SQL_ID} \
  --host=${DESTINATION_HOST} \
  --port=${DESTINATION_PORT} \
  --username=${DMS_USER} \
  --password=${DMS_PASS}
```

**Example for gcloud (AlloyDB Destination)**:

```bash
gcloud database-migration connection-profiles create postgresql \
  ${DEST_CONN_ID} \
  --region=${REGION} \
  --project=${PROJECT_ID} \
  --role=DESTINATION \
  --alloydb-cluster=${ALLOY_DEST_ID} \
  --host=${DESTINATION_HOST} \
  --port=${DESTINATION_PORT} \
  --username=${DMS_USER} \
  --password=${DMS_PASS}
```

### 6. Determine Migrated Databases

Check if the user wants to migrate specific databases or all databases of the
source PostgreSQL instance. Default to all databases if unclear.

### 7. Orchestrate Migration Job

Initialize, verify, and start the migration. The job must be created with the
`--use-postgres-native` flag (or equivalent config in Terraform) to enable
native logical replication.

*   **Creation**:

**Example for Terraform**:

```hcl
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

  state = "NOT_STARTED"

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
```

**Example for gcloud**:

```bash
gcloud database-migration migration-jobs create ${MJ_ID} \
  --region=${REGION} \
  --project=${PROJECT_ID} \
  --type=CONTINUOUS \
  --source=${SOURCE_CONN_ID} \
  --destination=${DEST_CONN_ID} \
  --use-postgres-native \
  --databases-filter=postgres \
  --no-async
```

*   **Verification and Start**:

**Example for Terraform**:

Update the migration job state to `RUNNING` and set `stop_on_warnings = true`
initially to get and present all warnings to the user.

```hcl
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
```

**Example for gcloud**:

```bash
gcloud database-migration migration-jobs verify ${MJ_ID} \
  --region=${REGION} \
  --project=${PROJECT_ID}

# Describe the verification operation to retrieve output
gcloud database-migration operations describe ${OP_ID} \
  --region=${REGION} \
  --project=${PROJECT_ID}

# Start the migration job
gcloud database-migration migration-jobs start ${MJ_ID} \
  --region=${REGION} \
  --project=${PROJECT_ID}
```

For `gcloud`, both verification and start operations return an operation ID.
Poll the operation until it finishes to retrieve any warnings or errors:

*   If verification returns warnings, ask the user if they are okay to ignore
    them.
*   If verification or start returns errors, troubleshoot them using available
    tools. Do not proceed until verification succeeds with no errors (warnings
    are acceptable and can be acknowledged/skipped).
*   After the verification step passes, execute the start command and wait for
    the start operation to fully complete.
