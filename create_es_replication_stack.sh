#!/bin/bash

# --- Configuration ---
REGION_SOUTH="ap-south-1"
REGION_EAST="us-east-1"
DOMAIN_SOUTH="poc-no-ccr-1"
DOMAIN_EAST="poc-no-ccr-1-dr"
INSTANCE_TYPE="t3.small.search"
KEY_NAME="suraj-test"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

RANDOM_HASH=$(openssl rand -hex 4)
BUCKET_NAME="replication-helper-bucket-$RANDOM_HASH"

echo "1. Creating S3 Bucket: $BUCKET_NAME..."
aws s3 mb s3://$BUCKET_NAME --region $REGION_SOUTH

echo "2. Starting OpenSearch Domain creation in parallel..."
aws opensearch create-domain --region $REGION_SOUTH --domain-name $DOMAIN_SOUTH \
  --engine-version Elasticsearch_6.7 --cluster-config InstanceType=$INSTANCE_TYPE,InstanceCount=1 \
  --ebs-options EBSEnabled=true,VolumeType=gp3,VolumeSize=10 > /dev/null &

aws opensearch create-domain --region $REGION_EAST --domain-name $DOMAIN_EAST \
  --engine-version Elasticsearch_6.7 --cluster-config InstanceType=$INSTANCE_TYPE,InstanceCount=1 \
  --ebs-options EBSEnabled=true,VolumeType=gp3,VolumeSize=10 > /dev/null &


echo "3. Waiting for OpenSearch Domains to become ACTIVE (usually 15 mins)..."
while true; do
    SOUTH_STATUS=$(aws opensearch describe-domain --region $REGION_SOUTH --domain-name $DOMAIN_SOUTH --query 'DomainStatus.Processing' --output text)
    EAST_STATUS=$(aws opensearch describe-domain --region $REGION_EAST --domain-name $DOMAIN_EAST --query 'DomainStatus.Processing' --output text)
    
    if [ "$SOUTH_STATUS" == "False" ] && [ "$EAST_STATUS" == "False" ]; then
        echo "Domains are ready!"
        break
    fi
    echo "Still creating... checking again in 60 seconds."
    sleep 60
done


echo "------------------------------------------------"
echo "Deployment Complete!"
echo "S3 Bucket: $BUCKET_NAME"
echo "Note: Configure OpenSearch access policies manually if needed"
echo "------------------------------------------------"
