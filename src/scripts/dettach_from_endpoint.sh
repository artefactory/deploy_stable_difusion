#!/bin/sh

TAG_VERSION="v1.0.0"
MODEL_DISPLAY_NAME="stable-diffusion:$TAG"
ENDPOINT_NAME="stable_diffusion"
REGION="europe-west1"

# Get the model id that match MODEL_DISPLAY_NAME
MODEL_ID=$(gcloud ai models list --region=$REGION --filter=displayName=$MODEL_DISPLAY_NAME --format='value(MODEL_ID)')
# Get the endpoint id that match ENDPOINT_NAME
ENDPOINT_ID=$(gcloud ai endpoints list --region=$REGION --filter=display_name=$ENDPOINT_NAME --format='value(ENDPOINT_ID)')


gcloud ai endpoints undeploy-model $ENDPOINT_ID \
    --region=$REGION \
    --deployed-model-id=$MODEL_ID \
