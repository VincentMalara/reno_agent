#!/bin/bash
set -euo pipefail

# Usage:
# bash infra/scripts/setup_github_iam.sh env/dev.env
# bash infra/scripts/setup_github_iam.sh env/prod.env

ENV_FILE="${1:?Usage: bash infra/scripts/setup_github_iam.sh env/dev.env}"

set -a
source "${ENV_FILE}"
set +a

: "${PROJECT_ID:?PROJECT_ID is required}"
: "${APP_ENV:?APP_ENV is required}"

SA_NAME="github-actions-${APP_ENV}"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
KEY_FILE="${SA_NAME}-key.json"
CLOUDBUILD_BUCKET="${PROJECT_ID}_cloudbuild"

echo "Setting up GitHub Actions IAM..."
echo "Project: ${PROJECT_ID}"
echo "Environment: ${APP_ENV}"
echo "Service account: ${SA_EMAIL}"

gcloud iam service-accounts create "${SA_NAME}" \
  --project="${PROJECT_ID}" \
  --display-name="GitHub Actions ${APP_ENV}" || true

echo "Waiting for service account propagation..."
sleep 10

for ROLE in \
  "roles/run.admin" \
  "roles/artifactregistry.writer" \
  "roles/cloudbuild.builds.editor" \
  "roles/iam.serviceAccountUser" \
  "roles/serviceusage.serviceUsageConsumer" \
  "roles/storage.objectAdmin" \
  "roles/storage.admin" \
  "roles/viewer"
do
  echo "Granting ${ROLE}..."
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="${ROLE}" \
    --condition=None
done

echo "Granting access to Cloud Build bucket: gs://${CLOUDBUILD_BUCKET}"

for BUCKET_ROLE in \
  "roles/storage.legacyBucketReader" \
  "roles/storage.objectAdmin"
do
  echo "Granting ${BUCKET_ROLE} on gs://${CLOUDBUILD_BUCKET}..."
  gcloud storage buckets add-iam-policy-binding "gs://${CLOUDBUILD_BUCKET}" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="${BUCKET_ROLE}" || true
done

if [[ -f "${KEY_FILE}" ]]; then
  echo "Key file already exists locally: ${KEY_FILE}"
  echo "Delete it first if you want to generate a new key."
else
  gcloud iam service-accounts keys create "${KEY_FILE}" \
    --project="${PROJECT_ID}" \
    --iam-account="${SA_EMAIL}"

  echo "Key created: ${KEY_FILE}"
  echo "Copy its content into GitHub Environment secret: GCP_SA_KEY"
fi

echo "GitHub Actions IAM setup completed successfully."