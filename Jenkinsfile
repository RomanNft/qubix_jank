pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials-id')
    }
    
    stages {
        stage('Check Credentials') {
            steps {
                script {
                    if (DOCKERHUB_CREDENTIALS == null) {
                        error "Credentials 'dockerhub-credentials-id' not found. Please add them to Jenkins."
                    } else {
                        echo "Credentials found: ${DOCKERHUB_CREDENTIALS}"
                    }
                }
            }
        }
        
        stage('Build and Push Images') {
            steps {
                script {
                    // Build and push facebook-client image
                    docker.withRegistry('https://registry.hub.docker.com', DOCKERHUB_CREDENTIALS) {
                        def clientImage = docker.build('roman2447/facebook-client:latest', './facebook-client')
                        clientImage.push()
                    }
                    
                    // Build and push facebook-server image
                    docker.withRegistry('https://registry.hub.docker.com', DOCKERHUB_CREDENTIALS) {
                        def serverImage = docker.build('roman2447/facebook-server:latest', './facebook-server')
                        serverImage.push()
                    }
                }
            }
        }
        
        stage('Run Migrations') {
            steps {
                script {
                    // Build and run migration container
                    docker.image('roman2447/facebook-server:latest').inside {
                        sh 'dotnet tool install --global dotnet-ef'
                        sh './wait-for-postgres.sh db "dotnet ef database update --configuration Release"'
                    }
                }
            }
        }
        
        stage('Deploy with Docker Compose') {
            steps {
                script {
                    // Run docker-compose to deploy the services
                    sh 'docker-compose up -d'
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}
