def call(Map config) {
    pipeline {
        agent any

        environment {
            SNYK_TOKEN = credentials('snyk-token')
            SONAR_TOKEN = credentials('sonar-token')
        }

        stages {
            stage('Pre-Security Checks') {
                steps {
                    script {
                        echo "🔍 Starting DevSecOps Pipeline"
                        sh 'git --version'
                        sh 'docker --version'
                        sh 'trivy --version'
                        sh 'snyk --version'
                    }
                }
            }

            stage('Secret Detection') {
                steps {
                    script {
                        echo "🕵️ Scanning for secrets..."
                        sh '''
                            # Use git-secrets or truffleHog for secret detection
                            find . -name "*.java" -o -name "*.js" -o -name "*.py" | \
                            xargs grep -l "password\\|secret\\|key\\|token" || true
                        '''
                    }
                }
            }

            stage('SAST - SonarQube') {
                steps {
                    script {
                        echo "🔍 Running SonarQube analysis..."
                        withSonarQubeEnv('SonarQube') {
                            sh '''
                                sonar-scanner \
                                -Dsonar.projectKey=${JOB_NAME} \
                                -Dsonar.sources=. \
                                -Dsonar.host.url=${SONAR_HOST_URL} \
                                -Dsonar.login=${SONAR_TOKEN}
                            '''
                        }
                    }
                }
            }

            stage('Dependency Check') {
                parallel {
                    stage('Snyk Dependencies') {
                        steps {
                            script {
                                echo "📦 Scanning dependencies with Snyk..."
                                sh './security-tools/snyk/scripts/scan.sh .'
                            }
                        }
                    }

                    stage('OWASP Dependency Check') {
                        steps {
                            script {
                                echo "🛡️ Running OWASP Dependency Check..."
                                sh '''
                                    dependency-check \
                                    --project "DevSecOps-Pipeline" \
                                    --scan . \
                                    --format ALL \
                                    --out /tmp/security-reports \
                                    --failOnCVSS 7
                                '''
                            }
                        }
                    }
                }
            }

            stage('Build & Container Scan') {
                steps {
                    script {
                        echo "🏗️ Building Docker image..."
                        def imageName = "${config.imageName}:${env.BUILD_NUMBER}"

                        sh "docker build -t ${imageName} ."

                        echo "🐳 Scanning Docker image with Trivy..."
                        sh "./security-tools/trivy/scripts/scan-image.sh ${imageName}"
                    }
                }
            }

            stage('Quality Gate') {
                steps {
                    script {
                        timeout(time: 10, unit: 'MINUTES') {
                            waitForQualityGate abortPipeline: true
                        }
                    }
                }
            }
        }

        post {
            always {
                script {
                    // Archive security reports
                    archiveArtifacts artifacts: '/tmp/security-reports/**/*', fingerprint: true

                    // Publish test results
                    publishHTML([
                            allowMissing: false,
                            alwaysLinkToLastBuild: true,
                            keepAll: true,
                            reportDir: '/tmp/security-reports',
                            reportFiles: '*.html',
                            reportName: 'Security Reports'
                    ])
                }
            }

            failure {
                script {
                    // Send notifications
                    slackSend(
                            channel: '#devsecops-alerts',
                            color: 'danger',
                            message: "❌ Security scan failed for ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
                    )
                }
            }

            success {
                script {
                    slackSend(
                            channel: '#devsecops-alerts',
                            color: 'good',
                            message: "✅ Security scan passed for ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
                    )
                }
            }
        }
    }
}