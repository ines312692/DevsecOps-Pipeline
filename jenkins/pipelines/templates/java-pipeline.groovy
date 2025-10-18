@Library('devsecops-shared-library') _

pipeline {
    agent any

    tools {
        maven 'Maven-3.8'
        jdk 'JDK-11'
    }

    environment {
        IMAGE_NAME = "myapp-java"
        DOCKER_REGISTRY = "your-registry.com"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Security Scan') {
            steps {
                securityScan([
                        imageName: "${IMAGE_NAME}"
                ])
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo " Deploying to production..."
                    // Add deployment steps here
                }
            }
        }
    }
}