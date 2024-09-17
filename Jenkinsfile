pipeline {
    agent any

    environment {
        DOCKER_IMAGE_CLIENT = "roman2447/facebook-client:latest"
        DOCKER_IMAGE_SERVER = "roman2447/facebook-server:latest"
        DOCKER_IMAGE_MIGRATION = "roman2447/facebook-migration:latest"
        DOCKER_IMAGE_DB = "postgres:latest"
        DOCKER_IMAGE_JENKINS = "jenkins/jenkins:lts"
    }

    stages {
        stage('Build') {
            steps {
                echo 'Building the application...'
                script {
                    // Build the client application
                    dir('facebook-client') {
                        sh 'docker build -t $DOCKER_IMAGE_CLIENT .'
                    }

                    // Build the server application
                    dir('facebook-server') {
                        sh 'docker build -t $DOCKER_IMAGE_SERVER .'
                        sh 'docker build -f Dockerfile_MIGRATION -t $DOCKER_IMAGE_MIGRATION .'
                    }
                }
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                script {
                    // Add your test commands here
                    // For example, you can run unit tests or integration tests
                    // sh 'npm test'
                    // sh 'dotnet test'
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying the application...'
                script {
                    // Start the Docker Compose services
                    sh 'docker-compose up -d'
                }
            }
        }

        stage('Cleanup') {
            steps {
                echo 'Cleaning up...'
                script {
                    // Stop and remove Docker containers
                    sh 'docker-compose down'

                    // Remove Docker images
                    sh 'docker rmi $DOCKER_IMAGE_CLIENT $DOCKER_IMAGE_SERVER $DOCKER_IMAGE_MIGRATION'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
