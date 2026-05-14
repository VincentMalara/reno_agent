#!/bin/bash
set -euo pipefail

# Usage:
# bash infra/scripts/setup_iam.sh env/dev.env
#
# This script configures IAM permissions required by Cloud Run
# to call Vertex AI.
#
# It should be executed manually when setting up an environment,
# not on every deployment.

ENV_FILE="${1:?Usage: bash infra/scripts/setup_iam.sh env/dev.env}"

# Load environment variables from the selected env file.
# set -a automatically exports all sourced variables.
set -a
source "${ENV_FILE}"
set +a

# Required variables expected in env/dev.env or env/prod.env:
# PROJECT_ID:        GCP project where Cloud Run is deployed
# VERTEX_PROJECT:    GCP project where Vertex AI is used

echo "Setting IAM permissions..."
echo "Cloud Run project: ${PROJECT_ID}"
echo "Vertex AI project: ${VERTEX_PROJECT}"

# Get the numeric project number of the Cloud Run project.
# The default Cloud Run service account usually has this format:
# PROJECT_NUMBER-compute@developer.gserviceaccount.com
PROJECT_NUMBER=$(gcloud projects describe "${PROJECT_ID}" \
  --format="value(projectNumber)")

CLOUD_RUN_SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

echo "Cloud Run service account: ${CLOUD_RUN_SERVICE_ACCOUNT}"

# Grant Cloud Run permission to call Vertex AI.
# This is required when using LiteLLM with models like:
# vertex_ai/gemini-2.5-flash-lite
gcloud projects add-iam-policy-binding "${VERTEX_PROJECT}" \
  --member="serviceAccount:${CLOUD_RUN_SERVICE_ACCOUNT}" \
  --role="roles/aiplatform.user"

echo "IAM setup completed successfully."