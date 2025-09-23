#!/bin/bash

echo "🚀 Setting up DevSecOps Pipeline..."

# Create directories
mkdir -p {jenkins,security-tools,monitoring,scripts,configs}

# Start services
echo "📦 Starting Docker containers..."
docker-compose up -d

# Wait for services
echo "⏳ Waiting for services to start..."
sleep 30

# Configure Jenkins
echo "🔧 Configuring Jenkins..."
curl -X POST http://localhost:8080/reload-configuration-as-code

# Configure SonarQube
echo "🔧 Setting up SonarQube..."
./scripts/setup/setup-sonarqube.sh

echo "✅ DevSecOps Pipeline setup completed!"
echo "🌐 Access URLs:"
echo "   Jenkins: http://localhost:8080 (admin/admin123)"
echo "   SonarQube: http://localhost:9000 (admin/admin)"
echo "   Grafana: http://localhost:3000 (admin/admin123)"