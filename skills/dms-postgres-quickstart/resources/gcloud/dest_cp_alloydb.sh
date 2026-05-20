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
