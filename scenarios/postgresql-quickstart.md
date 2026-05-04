# Scenario: PostgreSQL Quickstart Migration

This scenario focuses on migrating PostgreSQL databases into Cloud SQL for
PostgreSQL or AlloyDB for PostgreSQL. **Reference Guide**:
[PostgreSQL Quickstart Docs](https://docs.cloud.google.com/database-migration/docs/postgres/quick-start-migrations-guide)

--------------------------------------------------------------------------------

## Configuration Steps

### 1. Identify Destination and Context (Project & Region)

Determine the project and region for the destination instance (either Cloud SQL
for PostgreSQL or AlloyDB for PostgreSQL).

-   If not clear from user prompt, confirm the destination project and region.
-   **Action**: Use this project and region for all allocated resources (Private
    Connections, Connection Profiles, and Migration Jobs).

### 2. Identify Source Configuration

Source type: Self-managed, Cloud SQL, or AWS RDS Postgres.

-   **Discovery**: Analyze `.tfstate` files for existing database instances.
-   **Fallback**: If Terraform is unavailable, ask for the **Host**, **Port**,
    **Username**, **Password**, and **VPC** that allows reaching the source by
    the given host and port.
-   **Networking**:
    -   If using a Public IP or a host that resolves to a Public IP, inform the
        user and recommend/deploy a bastion host that forwards traffic to that
        Public IP.

### 3. Connectivity: Private Service Connect Interface

Quickstart migrations **strictly require** Private Service Connect interface
connectivity.

-   **Discovery**: Search for existing Private Connections in the destination
    project/region pointing to the source VPC.
-   **Validation**: Must be a PSCI-based connection in the `CREATED` state.
-   **Creation**: If missing, create a new Private Connection. Note that Private
    Connection creation is a long-running operation; wait for it to complete.

### 4. Source Connection Profile

Create and validate the gateway to the source. Note: Always use `template1` as
the database.

```bash
gcloud database-migration connection-profiles create postgresql \
  ${SOURCE_CONN_ID} --region=${REGION} --role=SOURCE \
  --host=${SOURCE_INSTANCE_IP} --port=${SOURCE_PORT} \
  --username=${SOURCE_USER} --password=${SOURCE_PASSWORD} \
  --database=template1 \
  --private-connection=${PRIVATE_CONN} --project=${PROJECT_ID}
```

If connection profile creation fails or the profile remains in a `FAILED` state,
troubleshoot and resolve errors before proceeding.

### 5. Destination Connection Profile

DMS requires a specific user with `cloudsqlsuperuser` (Cloud SQL) or
`alloydbsuperuser` (AlloyDB) privileges. Create it using available tools (rather
than direct SQL execution).

-   **Creation (AlloyDB)**:

```bash
gcloud database-migration connection-profiles create postgresql \
  ${DEST_CONN_ID} --region=${REGION} --role=DESTINATION \
  --alloydb-cluster=${ALLOY_DEST_ID} --host=${DESTINATION_HOST} \
  --port=${DESTINATION_PORT} --username=${DMS_USER} \
  --password=${DMS_PASS} --project=${PROJECT_ID}
```

-   **Creation (Cloud SQL)**:

```bash
gcloud database-migration connection-profiles create postgresql \
  ${DEST_CONN_ID} --region=${REGION} --role=DESTINATION \
  --cloudsql-instance=${CLOUD_SQL_ID} --host=${DESTINATION_HOST} \
  --port=${DESTINATION_PORT} --username=${DMS_USER} \
  --password=${DMS_PASS} --project=${PROJECT_ID}
```

### 6. Orchestrate Migration Job

Initialize, verify, and start the migration. The job must be created with the
`--use-postgres-native` flag to enable native logical replication.

-   **Creation**:

```bash
gcloud database-migration migration-jobs create ${MJ_ID} \
  --region=${REGION} --type=CONTINUOUS --source=${SOURCE_CONN_ID} \
  --destination=${DEST_CONN_ID} --use-postgres-native \
  --no-async --project=${PROJECT_ID}
```

-   **Verification**: Run `gcloud database-migration migration-jobs verify ...`.
    Troubleshoot any preflight errors using available SQL tools if
    database-level fixes are needed. Do not proceed until verification returns
    no errors (warnings are acceptable).
-   **Execution**: Start the job and wait for the Start operation to finish.
