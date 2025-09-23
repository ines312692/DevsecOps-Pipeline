#!/bin/bash

PROJECT_PATH=$1
REPORT_DIR="/tmp/security-reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p $REPORT_DIR

echo "🔍 Starting Snyk security scan..."

cd $PROJECT_PATH

# Authenticate with Snyk
snyk auth $SNYK_TOKEN

# Test for vulnerabilities
echo "📦 Scanning dependencies..."
snyk test \
    --json \
    --file=package.json \
    > "$REPORT_DIR/snyk-deps-$TIMESTAMP.json"

# Test Docker image if Dockerfile exists
if [ -f "Dockerfile" ]; then
    echo "🐳 Scanning Docker image..."
    snyk test \
        --docker \
        --file=Dockerfile \
        --json \
        > "$REPORT_DIR/snyk-docker-$TIMESTAMP.json"
fi

# Code analysis
echo "💻 Scanning source code..."
snyk code test \
    --json \
    > "$REPORT_DIR/snyk-code-$TIMESTAMP.json"

# Generate combined report
snyk test \
    --json \
    | snyk-to-html \
    -o "$REPORT_DIR/snyk-report-$TIMESTAMP.html"

echo "📊 Snyk scan completed. Reports saved to: $REPORT_DIR"