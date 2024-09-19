pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('my_service_')
    }

    stages {
        stage('Checkout') {
            steps {
                // Clone the repository
                git url: 'https://github.com/RomanNft/qwqaz.git'
            }
        }

        stage('Build') {
            steps {
                // Build the Docker images for server and client
                script {
                    sh 'docker build -t roman2447/facebook-server:latest ./facebook-server'
                    sh 'docker build -t roman2447/facebook-client:latest ./facebook-client'
                }
            }
        }

        stage('Test') {
            steps {
                // Add any testing steps here
                echo 'Running tests...'
                // e.g., sh 'docker run --rm your-test-image'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'DOCKER_HUB_CREDENTIALS') {
                        sh 'docker push roman2447/facebook-server:latest'
                        sh 'docker push roman2447/facebook-client:latest'
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                // Use docker-compose for deployment
                sh 'docker-compose down'
                sh 'docker-compose up -d'
            }
        }
    }

    post {
        always {
            echo 'Sending notifications...'
            // Add code here for post-build actions, like sending notifications
        }
    }
}
