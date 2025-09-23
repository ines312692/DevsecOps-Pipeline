FROM jenkins/jenkins:lts

USER root

# Install Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh

# Install additional tools
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Trivy
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Install Snyk
RUN npm install -g snyk

# Install OWASP Dependency Check
RUN wget -O dependency-check.zip https://github.com/jeremylong/DependencyCheck/releases/download/v8.4.0/dependency-check-8.4.0-release.zip \
    && unzip dependency-check.zip -d /opt/ \
    && ln -s /opt/dependency-check/bin/dependency-check.sh /usr/local/bin/dependency-check

# Copy Jenkins plugins list
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Copy Jenkins configuration
COPY jenkins.yml /var/jenkins_home/casc_configs/jenkins.yml

USER jenkins