#!/bin/bash

PROJECT_ID=$1
SERVICE_NAME=reno-agent
REGION=europe-west1

gcloud run deploy $SERVICE_NAME \
  --image gcr.io/$PROJECT_ID/$SERVICE_NAME \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --port 8080