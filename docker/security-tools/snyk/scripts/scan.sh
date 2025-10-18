#!/bin/bash

set -e

SNYK_TOKEN=${SNYK_TOKEN:-""}
PROJECT_PATH=${1:-.}
SEVERITY=${2:-high}

if [ -z "$SNYK_TOKEN" ]; then
    echo "Error: SNYK_TOKEN not set"
    exit 1
fi

echo "Authenticating Snyk..."
snyk auth $SNYK_TOKEN

echo "Running Snyk test on $PROJECT_PATH with severity threshold: $SEVERITY"
snyk test --severity-threshold=$SEVERITY --all-projects --json-file-output=reports/snyk-report.json || true

echo "Running Snyk monitor..."
snyk monitor --all-projects

echo "Snyk scan completed"