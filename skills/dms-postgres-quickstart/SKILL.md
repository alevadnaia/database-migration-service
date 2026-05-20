---
name: dms-postgres-quickstart
description: >-
  Executes a homogeneous PostgreSQL quickstart migration to Cloud SQL for
  PostgreSQL or AlloyDB for PostgreSQL using Private Service Connect Interface
  (PSCI) connectivity. Guides connectivity, connection profiles, and migration
  job verification/starts.
---

# Scenario: PostgreSQL Quickstart Migration

This scenario focuses on migrating PostgreSQL databases into Cloud SQL for
PostgreSQL or AlloyDB for PostgreSQL.

### Public Documentation & Technical Knowledge Base
If a user has technical questions about Postgres quickstart limitations,
unsupported PG features, compatibility matrices, network structures, or general
behaviors, you **MUST** refer to the public documentation:
*   **Primary Reference Guideline**: [PostgreSQL Quickstart Docs](https://cloud.google.com/database-migration/docs/postgres/quickstart)

Proactively look up or search the contents from this URL using available search
and page retrieval tools (e.g. `search_web` or `lookup_uri`) to verify details
before answering complex user queries.

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

#### Resource Code Templates:
*   **Terraform Definition**: [resources/terraform/private_connection.tf](file:///google/src/cloud/alevadnaia/WS_2/google3/cloud/dms/agents/migration-agent/database-migration-service/skills/dms-postgres-quickstart/resources/terraform/private_connection.tf)
*   **gcloud Commmand**: [resources/gcloud/private_connection.sh](file:///google/src/cloud/alevadnaia/WS_2/google3/cloud/dms/agents/migration-agent/database-migration-service/skills/dms-postgres-quickstart/resources/gcloud/private_connection.sh)

### 4. Source Connection Profile

Create and validate the gateway to the source. Note: Always use `template1` as
the database.

#### Resource Code Templates:
*   **Terraform Definition**: [resources/terraform/source_cp.tf](file:///google/src/cloud/alevadnaia/WS_2/google3/cloud/dms/agents/migration-agent/database-migration-service/skills/dms-postgres-quickstart/resources/terraform/source_cp.tf)
*   **gcloud Command**: [resources/gcloud/source_cp.sh](file:///google/src/cloud/alevadnaia/WS_2/google3/cloud/dms/agents/migration-agent/database-migration-service/skills/dms-postgres-quickstart/resources/gcloud/source_cp.sh)

If connection profile creation fails or the profile remains in a `FAILED` state,
troubleshoot and resolve errors before proceeding.

### 5. Destination Connection Profile

Create a user on the destination instance for migration purposes using available
tools (rather than direct SQL execution). Ensure the created user has
`cloudsqlsuperuser` (Cloud SQL) or `alloydbsuperuser` (AlloyDB) privileges. Do
not ask the user before creating the user; just create it. Then proceed to
destination connection profile creation.

#### Resource Code Templates (Cloud SQL Destination):
*   **Terraform Definition**: [resources/terraform/dest_cp_cloudsql.tf](file:///google/src/cloud/alevadnaia/WS_2/google3/cloud/dms/agents/migration-agent/database-migration-service/skills/dms-postgres-quickstart/resources/terraform/dest_cp_cloudsql.tf)
*   **gcloud Command**: [resources/gcloud/dest_cp_cloudsql.sh](file:///google/src/cloud/alevadnaia/WS_2/google3/cloud/dms/agents/migration-agent/database-migration-service/skills/dms-postgres-quickstart/resources/gcloud/dest_cp_cloudsql.sh)

#### Resource Code Templates (AlloyDB Destination):
*   **Terraform Definition**: [resources/terraform/dest_cp_alloydb.tf](file:///google/src/cloud/alevadnaia/WS_2/google3/cloud/dms/agents/migration-agent/database-migration-service/skills/dms-postgres-quickstart/resources/terraform/dest_cp_alloydb.tf)
*   **gcloud Command**: [resources/gcloud/dest_cp_alloydb.sh](file:///google/src/cloud/alevadnaia/WS_2/google3/cloud/dms/agents/migration-agent/database-migration-service/skills/dms-postgres-quickstart/resources/gcloud/dest_cp_alloydb.sh)

### 6. Determine Migrated Databases

Check if the user wants to migrate specific databases or all databases of the
source PostgreSQL instance. Default to all databases if unclear.

### 7. Orchestrate Migration Job

Initialize, verify, and start the migration. The job must be created with the
`--use-postgres-native` flag (or equivalent config in Terraform) to enable
native logical replication.

#### Resource Code Templates:
*   **Terraform Definition**: [resources/terraform/migration_job.tf](file:///google/src/cloud/alevadnaia/WS_2/google3/cloud/dms/agents/migration-agent/database-migration-service/skills/dms-postgres-quickstart/resources/terraform/migration_job.tf)
*   **gcloud Commands (Verify / Describe / Start)**: [resources/gcloud/migration_job.sh](file:///google/src/cloud/alevadnaia/WS_2/google3/cloud/dms/agents/migration-agent/database-migration-service/skills/dms-postgres-quickstart/resources/gcloud/migration_job.sh)

#### Execution and Monitoring Heuristics:
*   For Terraform, update the migration job state to `RUNNING` and set `stop_on_warnings = true` initially to get and present all warnings to the user.
*   For `gcloud`, both verification and start operations return an operation ID.
    Poll the operation until it finishes to retrieve any warnings or errors.
*   If verification returns warnings, ask the user if they are okay to ignore them.
*   If verification or start returns errors, troubleshoot them using available
    tools. Do not proceed until verification succeeds with no errors (warnings
    are acceptable and can be acknowledged/skipped).
*   After the verification step passes, execute the start command and wait for the
    start operation to fully complete.
*   Ensure that the start operation completes successfully and the migration
    transitions to a `RUNNING` state. If the operation fails, troubleshoot the
    root cause, fix any errors, and retry the operation.
*   In the final response, provide a direct link to the started migration job in the
    Google Cloud Console using exactly this URL format (where `<region>` replaces
    the region and `<migration_id>` replaces the migration job ID):
    `https://console.cloud.google.com/dbmigration/migrations/locations/<region>/instances/<migration_id>`
