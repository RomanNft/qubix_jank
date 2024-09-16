pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from the repository
                checkout scm
            }
        }

        stage('Build') {
            steps {
                // Build the client and server applications
                script {
                    // Build the client
                    dir('facebook-client') {
                        sh 'npm install'
                        sh 'npm run build'
                    }

                    // Build the server
                    dir('facebook-server') {
                        sh 'dotnet restore'
                        sh 'dotnet build --configuration Release'
                    }
                }
            }
        }

        stage('Test') {
            steps {
                // Run tests for the server application
                script {
                    dir('facebook-server') {
                        sh 'dotnet test --configuration Release'
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                // Build Docker images for client and server
                script {
                    // Build client Docker image
                    dir('facebook-client') {
                        sh 'docker build -t roman2447/facebook-client:latest .'
                    }

                    // Build server Docker image
                    dir('facebook-server') {
                        sh 'docker build -t roman2447/facebook-server:latest .'
                    }
                }
            }
        }

        stage('Docker Push') {
            steps {
                // Push Docker images to Docker Hub
                script {
                    // Push client Docker image
                    sh 'docker push roman2447/facebook-client:latest'

                    // Push server Docker image
                    sh 'docker push roman2447/facebook-server:latest'
                }
            }
        }

        stage('Deploy') {
            steps {
                // Deploy the application using Docker Compose
                script {
                    sh 'docker-compose up -d'
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
