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
