#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

ENV_FILE_INPUT="${1:?Usage: bash infra/scripts/build.sh env/dev.env}"
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
  PROJECT_ID
  REGION
  REPOSITORY
  IMAGE_NAME
  TAG
)

for name in "${required_vars[@]}"; do
  if [[ -z "${!name:-}" ]]; then
    echo "Missing required variable: ${name}" >&2
    exit 1
  fi
done

IMAGE_URI="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}:${TAG}"

echo "Building image with Cloud Build: ${IMAGE_URI}"

cd "${REPO_ROOT}"

gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet
gcloud builds submit \
  --project "${PROJECT_ID}" \
  --config infra/cloudbuild.yaml \
  --substitutions "_IMAGE_URI=${IMAGE_URI}" \
  .

echo "Image pushed: ${IMAGE_URI}"
