pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'DockerHub-Credential'
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from the repository
                git 'https://github.com/RomanNft/qwqaz'
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    // Build the Docker images for facebook-client, facebook-server, and migration
                    docker.build('roman2447/facebook-client:latest', 'facebook-client')
                    docker.build('roman2447/facebook-server:latest', 'facebook-server')
                    docker.build('roman2447/facebook-migration:latest', 'facebook-server', '-f Dockerfile_MIGRATION')
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                script {
                    // Push Docker images to Docker Hub
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) {
                        docker.image('roman2447/facebook-client:latest').push('latest')
                        docker.image('roman2447/facebook-server:latest').push('latest')
                        docker.image('roman2447/facebook-migration:latest').push('latest')
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Run Docker Compose to deploy the services
                    sh 'docker-compose up --build -d'
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    // Optionally, you might want to clean up Docker images or containers
                    sh 'docker system prune -f'
                }
            }
        }
    }

    post {
        always {
            // Archive Docker logs or other necessary artifacts
            archiveArtifacts artifacts: 'facebook-client/logs/**/*, facebook-server/logs/**/*', allowEmptyArchive: true
        }
        success {
            // Actions on successful build
            echo 'Build and deployment were successful!'
        }
        failure {
            // Actions on failed build
            echo 'Build or deployment failed.'
        }
    }
}
