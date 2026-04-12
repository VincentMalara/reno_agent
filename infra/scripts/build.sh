#!/bin/bash

PROJECT_ID=$1
IMAGE_NAME=reno-agent

gcloud builds submit --tag gcr.io/$PROJECT_ID/$IMAGE_NAME