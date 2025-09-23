.PHONY: setup start stop restart logs clean

# Setup and start the DevSecOps pipeline
setup:
	@echo "🚀 Setting up DevSecOps Pipeline..."
	./scripts/setup/install-tools.sh

# Start all services
start:
	@echo "▶️ Starting services..."
	docker-compose up -d

# Stop all services
stop:
	@echo "⏹️ Stopping services..."
	docker-compose down

# Restart all services
restart: stop start

# View logs
logs:
	docker-compose logs -f

# Clean up everything
clean:
	@echo "🧹 Cleaning up..."
	docker-compose down -v
	docker system prune -f

# Run security scan
security-scan:
	@echo "🔍 Running security scan..."
	./scripts/automation/security-scan.py

# Generate reports
reports:
	@echo "📊 Generating security reports..."
	./scripts/utilities/report-generator.py