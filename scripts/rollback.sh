#!/bin/bash
set -euo pipefail

# Rollback Script
# Usage: ./rollback.sh [frontend|backend|all] <optional-image-tag>

ROLLBACK_TYPE=${1:-all}
IMAGE_TAG=${2:-${BACKEND_DOCKER_IMAGE:-}}
REGION=${AWS_REGION:-us-east-1}

rollback_frontend() {
  S3_BUCKET=${S3_BUCKET_NAME:-}
  if [ -z "$S3_BUCKET" ]; then
    echo "Error: S3_BUCKET_NAME not set"
    exit 1
  fi

  echo "Rolling back frontend..."
  echo "Note: Requires S3 versioning enabled for index.html"

  VERSION_ID=$(aws s3api list-object-versions \
    --bucket "$S3_BUCKET" \
    --query 'Versions[?Key==`index.html`] | sort_by(@, &LastModified) | [-2].VersionId' \
    --output text)

  if [ -z "$VERSION_ID" ] || [ "$VERSION_ID" = "None" ]; then
    echo "No previous version found. Ensure S3 versioning is enabled."
    exit 1
  fi

  aws s3api copy-object \
    --bucket "$S3_BUCKET" \
    --copy-source "$S3_BUCKET/index.html?versionId=$VERSION_ID" \
    --key "index.html"

  echo "Frontend rollback completed"
}

rollback_backend() {
  ASG_NAME=${AUTO_SCALING_GROUP_NAME:-}
  if [ -z "$ASG_NAME" ]; then
    echo "Error: AUTO_SCALING_GROUP_NAME not set"
    exit 1
  fi

  if [ -z "$IMAGE_TAG" ]; then
    echo "Error: BACKEND_DOCKER_IMAGE not provided"
    exit 1
  fi

  echo "Rolling back backend to image: $IMAGE_TAG"

  INSTANCES=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "$ASG_NAME" \
    --region "$REGION" \
    --query 'AutoScalingGroups[0].Instances[*].InstanceId' \
    --output text)

  for instance in $INSTANCES; do
    aws ssm send-command \
      --region "$REGION" \
      --document-name "AWS-RunShellScript" \
      --instance-ids "$instance" \
      --parameters "commands=[
        \"docker pull $IMAGE_TAG\",
        \"docker stop muchtodo-api || true\",
        \"docker rm muchtodo-api || true\",
        \"docker run -d --name muchtodo-api --restart unless-stopped -p 8080:8080 \\\n          -e MONGO_URI=\"${MONGO_URI:-}\" \\\n          -e REDIS_ADDR=\"${REDIS_ADDR:-}\" \\\n          -e JWT_SECRET_KEY=\"${JWT_SECRET_KEY:-}\" \\\n          $IMAGE_TAG\"
      ]" \
      --output text >/dev/null
  done

  echo "Backend rollback completed"
}

case "$ROLLBACK_TYPE" in
  frontend)
    rollback_frontend
    ;;
  backend)
    rollback_backend
    ;;
  all)
    rollback_frontend
    rollback_backend
    ;;
  *)
    echo "Usage: ./rollback.sh [frontend|backend|all] <optional-image-tag>"
    exit 1
    ;;
 esac
