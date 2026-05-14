#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

ENV_FILE_INPUT="${1:?Usage: bash infra/scripts/deploy.sh env/dev.env}"
if [[ "${ENV_FILE_INPUT}" = /* ]]; then
  ENV_FILE="${ENV_FILE_INPUT}"
else
  ENV_FILE="${REPO_ROOT}/${ENV_FILE_INPUT}"
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Environment file not found: ${ENV_FILE}" >&2
  exit 1
fi

set -a
source "${ENV_FILE}"
set +a

required_vars=(
  APP_ENV
  PROJECT_ID
  REGION
  REPOSITORY
  IMAGE_NAME
  SERVICE_NAME
  TAG
  LLM_MODEL
  VERTEX_PROJECT
  VERTEX_LOCATION
)

for name in "${required_vars[@]}"; do
  if [[ -z "${!name:-}" ]]; then
    echo "Missing required variable: ${name}" >&2
    exit 1
  fi
done

IMAGE_URI="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}:${TAG}"

echo "Deploying ${APP_ENV} to Cloud Run service ${SERVICE_NAME}"
echo "Image: ${IMAGE_URI}"

bash "${SCRIPT_DIR}/build.sh" "${ENV_FILE}"

gcloud run deploy "${SERVICE_NAME}" \
  --image "${IMAGE_URI}" \
  --project "${PROJECT_ID}" \
  --platform managed \
  --region "${REGION}" \
  --allow-unauthenticated \
  --quiet \
  --port 8080 \
  --set-env-vars "APP_ENV=${APP_ENV},LLM_MODEL=${LLM_MODEL},VERTEX_PROJECT=${VERTEX_PROJECT},VERTEX_LOCATION=${VERTEX_LOCATION}"

SERVICE_URL="$(gcloud run services describe "${SERVICE_NAME}" \
  --project "${PROJECT_ID}" \
  --region "${REGION}" \
  --format 'value(status.url)')"

echo "Deployment completed: ${SERVICE_URL}"