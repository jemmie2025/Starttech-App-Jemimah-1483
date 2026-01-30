#!/bin/bash
set -euo pipefail

# Deploy Backend via Auto Scaling Group (SSM)
# Usage: ./deploy-backend.sh <asg-name> <docker-image> <region>

ASG_NAME=${1:-${AUTO_SCALING_GROUP_NAME:-}}
DOCKER_IMAGE=${2:-${BACKEND_DOCKER_IMAGE:-}}
REGION=${3:-${AWS_REGION:-us-east-1}}

if [ -z "$ASG_NAME" ]; then
  echo "Error: Auto Scaling Group name not provided"
  echo "Usage: ./deploy-backend.sh <asg-name> <docker-image> <region>"
  exit 1
fi

if [ -z "$DOCKER_IMAGE" ]; then
  echo "Error: Docker image not provided"
  exit 1
fi

echo "Deploying backend using ASG: $ASG_NAME"
echo "Docker image: $DOCKER_IMAGE"
echo "Region: $REGION"

INSTANCES=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "$ASG_NAME" \
  --region "$REGION" \
  --query 'AutoScalingGroups[0].Instances[*].InstanceId' \
  --output text)

if [ -z "$INSTANCES" ]; then
  echo "Error: No instances found in ASG $ASG_NAME"
  exit 1
fi

for instance in $INSTANCES; do
  echo "Updating instance $instance"
  aws ssm send-command \
    --region "$REGION" \
    --document-name "AWS-RunShellScript" \
    --instance-ids "$instance" \
    --parameters "commands=[
      \"docker pull $DOCKER_IMAGE\",
      \"docker stop muchtodo-api || true\",
      \"docker rm muchtodo-api || true\",
      \"docker run -d --name muchtodo-api --restart unless-stopped -p 8080:8080 \\\n        -e MONGO_URI=\"${MONGO_URI:-}\" \\\n        -e REDIS_ADDR=\"${REDIS_ADDR:-}\" \\\n        -e JWT_SECRET_KEY=\"${JWT_SECRET_KEY:-}\" \\\n        $DOCKER_IMAGE\"
    ]" \
    --output text >/dev/null

done

echo "Backend deployment completed successfully!"
