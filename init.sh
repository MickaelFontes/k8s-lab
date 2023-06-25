#!/bin/bash
set -xe

## Parameters TO CHANGE
REGION="us-east1" # region available for many free tier services
PROJECT_ID="$1"
RANDOM_CHARS=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 10 | head -n 1)

# Init gcloud CLI
gcloud auth login
gcloud auth application-default
gcloud config set project ${PROJECT_ID}
gcloud services enable container.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com # to edit iam policies

sleep 120 # to let APIs activate
gcloud storage buckets create gs://${PROJECT_ID}-${RANDOM_CHARS} --project=${PROJECT_ID} --location=${REGION}
sleep 30 # for bucket creation
cp terraform.tfvars.example terraform.tfvars
sed -i "s/\(MANUAL_EDIT_WRITE_YOUR_BUCKET\)/${PROJECT_ID}-${RANDOM_CHARS}/m" ./main.tf
echo "Now edit the terraform.tfvars file with your configuration!"