#!/bin/bash
set -euo pipefail

ENV_FILE="${1:?Usage: bash infra/scripts/deploy.sh env/dev.env}"

source "${ENV_FILE}"

IMAGE_URI="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}:${TAG}"

echo "Building image: ${IMAGE_URI}"
gcloud builds submit \
  --project "${PROJECT_ID}" \
  --tag "${IMAGE_URI}" \

echo "Deploying service: ${SERVICE_NAME}"
gcloud run deploy "${SERVICE_NAME}" \
  --image "${IMAGE_URI}" \
  --project "${PROJECT_ID}" \
  --platform managed \
  --region "${REGION}" \
  --allow-unauthenticated \
  --port 8080