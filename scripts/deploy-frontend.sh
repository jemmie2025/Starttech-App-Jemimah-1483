#!/bin/bash
set -euo pipefail

# Deploy Frontend to S3 + CloudFront
# Usage: ./deploy-frontend.sh <s3-bucket> <build-dir> <cloudfront-id>

S3_BUCKET=${1:-${S3_BUCKET_NAME:-}}
BUILD_DIR=${2:-dist}
CLOUDFRONT_ID=${3:-${CLOUDFRONT_DISTRIBUTION_ID:-}}

if [ -z "$S3_BUCKET" ]; then
  echo "Error: S3 bucket name not provided"
  echo "Usage: ./deploy-frontend.sh <s3-bucket> <build-dir> <cloudfront-id>"
  exit 1
fi

if [ ! -d "$BUILD_DIR" ]; then
  echo "Error: Build directory not found at $BUILD_DIR"
  exit 1
fi

echo "Deploying frontend to S3 bucket: $S3_BUCKET"

# Sync static assets with long cache
aws s3 sync "$BUILD_DIR/" "s3://$S3_BUCKET/" \
  --delete \
  --cache-control "public, max-age=31536000" \
  --exclude "index.html"

echo "Uploaded static assets"

# Upload index.html with no-cache
aws s3 cp "$BUILD_DIR/index.html" "s3://$S3_BUCKET/index.html" \
  --cache-control "public, max-age=0, must-revalidate" \
  --content-type "text/html"

echo "Uploaded index.html"

# Optional CloudFront invalidation
if [ -n "$CLOUDFRONT_ID" ]; then
  echo "Invalidating CloudFront distribution: $CLOUDFRONT_ID"
  aws cloudfront create-invalidation \
    --distribution-id "$CLOUDFRONT_ID" \
    --paths "/*" >/dev/null
  echo "CloudFront invalidation initiated"
else
  echo "CloudFront distribution ID not provided, skipping invalidation"
fi

echo "Frontend deployment completed successfully!"
