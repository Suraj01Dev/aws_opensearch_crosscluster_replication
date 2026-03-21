#!/bin/bash

# --- Configuration (Must match deployment script) ---
REGION_SOUTH="ap-south-1"
REGION_EAST="us-east-1"
DOMAIN_SOUTH="poc-no-ccr-1"
DOMAIN_EAST="poc-no-ccr-1-dr"

echo "1. Deleting OpenSearch Domains..."
aws opensearch delete-domain --region $REGION_SOUTH --domain-name $DOMAIN_SOUTH > /dev/null &
aws opensearch delete-domain --region $REGION_EAST --domain-name $DOMAIN_EAST > /dev/null &
echo "Deletion requests sent for $DOMAIN_SOUTH and $DOMAIN_EAST."

echo "3. S3 Bucket Cleanup"
read -p "Enter the full name of the S3 bucket to delete: " BUCKET_NAME

if [ -n "$BUCKET_NAME" ]; then
    echo "Emptying and deleting bucket: $BUCKET_NAME..."
    # 'rb --force' deletes all objects and then the bucket itself
    aws s3 rb s3://$BUCKET_NAME --force --region $REGION_SOUTH
else
    echo "No bucket name provided. Skipping S3 deletion."
fi

echo "------------------------------------------------"
echo "Cleanup Process Initiated!"
echo "Note: OpenSearch domains take ~15-20 mins to fully disappear."
echo "------------------------------------------------"
