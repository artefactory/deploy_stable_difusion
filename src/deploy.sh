#!/bin/sh
TAG_VERSION="v1.0.0"

PROJECT_ID=""
IMAGE_NAME="stable-diffusion"
REGION="europe-west1"
SERVICE_ACCOUNT_ENDPOINT="default service account or custom service account if you need specific rights"

MODEL_DISPLAY_NAME="stable-diffusion:$TAG_VERSION"
ENDPOINT_NAME="stable_diffusion"
CONTAINER_IMAGE_URI="eu.gcr.io/$PROJECT_ID/stable_diffusion:$TAG_VERSION"

BUILD_TIMEOUT="3600s"
CONTAINER_PORT=7080

MACHINE_TYPE="n1-highmem-8"
ACCELERATOR_TYPE="nvidia-tesla-t4"

echo "-------- Building the image on cloud build --------"

gcloud builds submit --config cloudbuild.yaml \
    --timeout=$BUILD_TIMEOUT \
    --substitutions=_CONTAINER_IMAGE_URI=$CONTAINER_IMAGE_URI

echo "----------- Upload model on Vertex AI -------------"

gcloud ai models upload \
    --region=$REGION \
    --display-name=$MODEL_DISPLAY_NAME \
    --container-image-uri=$CONTAINER_IMAGE_URI \
    --container-ports=$CONTAINER_PORT \
    --container-health-route=/ping \
    --container-predict-route=/predictions/$IMAGE_NAME

echo "------------ Deploy model to endpoint -------------"

ENDPOINT_ID=$(gcloud ai endpoints list --region=$REGION --filter=display_name=$ENDPOINT_NAME --format='value(ENDPOINT_ID)')

if [ -z "$ENDPOINT_ID" ]; then
    echo "Endpoint named $ENDPOINT_NAME doesn't exist, creating it..."
    gcloud ai endpoints create \
        --region=$REGION \
        --display-name=$ENDPOINT_NAME
    ENDPOINT_ID=$(gcloud ai endpoints list --region=$REGION --filter=display_name=$ENDPOINT_NAME --format='value(ENDPOINT_ID)')
fi

# TODO : Update command take only the latest version
MODEL_ID=$(gcloud ai models list --region=$REGION --filter=displayName=$MODEL_DISPLAY_NAME --format='value(MODEL_ID)')

gcloud beta ai endpoints deploy-model $ENDPOINT_ID \
    --project=$PROJECT_ID \
    --region=$REGION \
    --model=$MODEL_ID \
    --display-name=$MODEL_DISPLAY_NAME \
    --machine-type=$MACHINE_TYPE \
    --accelerator=type=$ACCELERATOR_TYPE,count=1 \
    --traffic-split=0=100 \
    --service-account=$SERVICE_ACCOUNT_ENDPOINT \
    --enable-access-logging