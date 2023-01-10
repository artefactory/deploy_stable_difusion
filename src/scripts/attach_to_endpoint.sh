#!/bin/sh

SERVICE_ACCOUNT_ENDPOINT=""

TAG="v1.0.0"
MODEL_DISPLAY_NAME="stable-diffusion:$TAG"
ENDPOINT_NAME="stable_diffusion"
REGION="europe-west1"

MACHINE_TYPE="n1-highmem-8"
ACCELERATOR_TYPE="nvidia-tesla-t4"

# Get model ID that match MODEL_DISPLAY_NAME
MODEL_ID=$(gcloud ai models list --region=$REGION --filter=displayName=$MODEL_DISPLAY_NAME --format='value(MODEL_ID)')

# Get endpoint ID that match ENDPOINT_NAME
ENDPOINT_ID=$(gcloud ai endpoints list --region=$REGION --filter=display_name=$ENDPOINT_NAME --format='value(ENDPOINT_ID)')

gcloud ai endpoints deploy-model $ENDPOINT_ID \
    --region=$REGION \
    --model=$MODEL_ID \
    --display-name=$MODEL_DISPLAY_NAME \
    --machine-type=$MACHINE_TYPE \
    --accelerator=type=$ACCELERATOR_TYPE,count=1 \
    --traffic-split=0=100 \
    --service-account=$SERVICE_ACCOUNT_ENDPOINT \
    --enable-access-logging