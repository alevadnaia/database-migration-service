# 1. Create the continuous migration job using postgres native logical replication
gcloud database-migration migration-jobs create ${MJ_ID} \
  --region=${REGION} \
  --project=${PROJECT_ID} \
  --type=CONTINUOUS \
  --source=${SOURCE_CONN_ID} \
  --destination=${DEST_CONN_ID} \
  --use-postgres-native \
  --databases-filter=postgres \
  --no-async

# 2. Verify the migration job to check for warnings or blocks
gcloud database-migration migration-jobs verify ${MJ_ID} \
  --region=${REGION} \
  --project=${PROJECT_ID}

# Describe the verification operation to retrieve output
gcloud database-migration operations describe ${OP_ID} \
  --region=${REGION} \
  --project=${PROJECT_ID}

# 3. Start the migration job after verification succeeds
gcloud database-migration migration-jobs start ${MJ_ID} \
  --region=${REGION} \
  --project=${PROJECT_ID}
