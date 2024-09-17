pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'roman2447'
        DOCKER_HUB_CREDENTIALS = 'docker-hub-credentials'
    }

    stages {
        stage('Checkout') {
            steps {
                // Checking out the code from Git repository
                git branch: 'main', url: 'https://github.com/RomanNft/qwqaz'
            }
        }

        stage('Build facebook-client') {
            steps {
                script {
                    docker.build("${DOCKER_HUB_REPO}/facebook-client:latest", './facebook-client')
                }
            }
        }

        stage('Build facebook-server') {
            steps {
                script {
                    docker.build("${DOCKER_HUB_REPO}/facebook-server:latest", './facebook-server')
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_HUB_CREDENTIALS) {
                        docker.image("${DOCKER_HUB_REPO}/facebook-client:latest").push()
                        docker.image("${DOCKER_HUB_REPO}/facebook-server:latest").push()
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Run docker-compose to deploy all services
                    sh 'docker-compose down'
                    sh 'docker-compose up --build -d'
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            sh 'docker-compose down'
        }

        success {
            echo 'Deployment was successful!'
        }

        failure {
            echo 'Build or Deployment failed!'
        }
    }
}
