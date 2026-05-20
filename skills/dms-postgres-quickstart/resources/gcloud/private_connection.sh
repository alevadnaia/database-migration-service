gcloud database-migration private-connections create ${PRIVATE_CONN} \
  --region=${REGION} \
  --project=${PROJECT_ID} \
  --display-name=${PRIVATE_CONN} \
  --no-async \
  --network-attachment=${NETWORK_ATTACHMENT_URI}
