#!/bin/bash

IMAGE_NAME=$1
REPORT_DIR="/tmp/security-reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create report directory
mkdir -p $REPORT_DIR

echo "🔍 Starting Trivy scan for image: $IMAGE_NAME"

# Scan image for vulnerabilities
trivy image \
    --format json \
    --output "$REPORT_DIR/trivy-scan-$TIMESTAMP.json" \
    --severity HIGH,CRITICAL \
    --exit-code 1 \
    $IMAGE_NAME

# Generate HTML report
trivy image \
    --format template \
    --template "@/opt/trivy-templates/html.tpl" \
    --output "$REPORT_DIR/trivy-report-$TIMESTAMP.html" \
    $IMAGE_NAME

echo "📊 Trivy scan completed. Reports saved to: $REPORT_DIR"

# Check exit code
if [ $? -eq 0 ]; then
    echo "✅ No critical vulnerabilities found"
    exit 0
else
    echo "❌ Critical vulnerabilities detected!"
    exit 1
fi