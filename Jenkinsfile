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
                    sh "docker build -t ${DOCKER_HUB_REPO}/facebook-client:latest ./facebook-client"
                }
            }
        }

        stage('Build facebook-server') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_HUB_REPO}/facebook-server:latest ./facebook-server"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withDockerRegistry(credentialsId: DOCKER_HUB_CREDENTIALS, url: 'https://index.docker.io/v1/') {
                        sh "docker push ${DOCKER_HUB_REPO}/facebook-client:latest"
                        sh "docker push ${DOCKER_HUB_REPO}/facebook-server:latest"
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
