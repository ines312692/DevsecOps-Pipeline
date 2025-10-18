#!/bin/bash

set -e

echo "=== DevSecOps Pipeline Setup ==="

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

echo -e "${YELLOW}Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker $SUDO_USER
    echo -e "${GREEN}Docker installed successfully${NC}"
else
    echo -e "${YELLOW}Docker already installed${NC}"
fi

echo -e "${YELLOW}Installing Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}Docker Compose installed successfully${NC}"
else
    echo -e "${YELLOW}Docker Compose already installed${NC}"
fi

echo -e "${YELLOW}Installing Trivy...${NC}"
if ! command -v trivy &> /dev/null; then
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list
    apt-get update && apt-get install -y trivy
    echo -e "${GREEN}Trivy installed successfully${NC}"
else
    echo -e "${YELLOW}Trivy already installed${NC}"
fi

echo -e "${YELLOW}Installing Snyk CLI...${NC}"
if ! command -v snyk &> /dev/null; then
    npm install -g snyk
    echo -e "${GREEN}Snyk installed successfully${NC}"
else
    echo -e "${YELLOW}Snyk already installed${NC}"
fi

echo -e "${YELLOW}Installing OWASP Dependency-Check...${NC}"
if ! command -v dependency-check.sh &> /dev/null; then
    wget https://github.com/jeremylong/DependencyCheck_Plugin/releases/download/v8.4.2/dependency-check_8.4.2_all.deb
    dpkg -i dependency-check_8.4.2_all.deb
    rm dependency-check_8.4.2_all.deb
    echo -e "${GREEN}Dependency-Check installed successfully${NC}"
else
    echo -e "${YELLOW}Dependency-Check already installed${NC}"
fi

echo -e "${YELLOW}Installing Falco...${NC}"
if ! command -v falco &> /dev/null; then
    curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | apt-key add -
    echo "deb https://download.falco.org/packages/deb stable main" | tee /etc/apt/sources.list.d/falcosecurity.list
    apt-get update && apt-get install -y falco
    echo -e "${GREEN}Falco installed successfully${NC}"
else
    echo -e "${YELLOW}Falco already installed${NC}"
fi

echo -e "${YELLOW}Installing SonarQube Scanner...${NC}"
if ! command -v sonar-scanner &> /dev/null; then
    wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
    unzip sonar-scanner-cli-5.0.1.3006-linux.zip
    mv sonar-scanner-5.0.1.3006-linux /opt/sonar-scanner
    ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
    rm sonar-scanner-cli-5.0.1.3006-linux.zip
    echo -e "${GREEN}SonarQube Scanner installed successfully${NC}"
else
    echo -e "${YELLOW}SonarQube Scanner already installed${NC}"
fi

echo -e "${YELLOW}Installing Git Secrets...${NC}"
if ! command -v git-secrets &> /dev/null; then
    git clone https://github.com/awslabs/git-secrets.git
    cd git-secrets
    make install
    cd ..
    rm -rf git-secrets
    echo -e "${GREEN}Git Secrets installed successfully${NC}"
else
    echo -e "${YELLOW}Git Secrets already installed${NC}"
fi

echo -e "${GREEN}=== Installation Complete ===${NC}"