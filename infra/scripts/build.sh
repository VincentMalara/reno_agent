#!/bin/bash
set -euo pipefail

PROJECT_ID="${1:?PROJECT_ID is required}"
REGION="${2:?REGION is required}"
REPOSITORY="${3:?REPOSITORY is required}"
IMAGE_NAME="${4:-reno-agent}"
TAG="${5:-latest}"

IMAGE_URI="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}:${TAG}"

echo "Building image: ${IMAGE_URI}"

gcloud builds submit \
  --project "${PROJECT_ID}" \
  --tag "${IMAGE_URI}" \