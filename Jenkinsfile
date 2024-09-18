pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'roman2447'
        DOCKER_HUB_CREDENTIALS = 'my_service_credentials'
    }

    stages {
        stage('Check Environment') {
            steps {
                script {
                    sh 'env'
                }
            }
        }

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/RomanNft/qwqaz'
            }
        }

        stage('Build facebook-client') {
            steps {
                script {
                    try {
                        sh 'docker --version'
                        docker.build("${DOCKER_HUB_REPO}/facebook-client:latest", './facebook-client')
                    } catch (Exception e) {
                        echo "Failed to build facebook-client: ${e.getMessage()}"
                        throw e
                    }
                }
            }
        }

        stage('Build facebook-server') {
            steps {
                script {
                    try {
                        sh 'docker --version'
                        docker.build("${DOCKER_HUB_REPO}/facebook-server:latest", './facebook-server')
                    } catch (Exception e) {
                        echo "Failed to build facebook-server: ${e.getMessage()}"
                        throw e
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    try {
                        docker.withRegistry('https://index.docker.io/v1/', DOCKER_HUB_CREDENTIALS) {
                            docker.image("${DOCKER_HUB_REPO}/facebook-client:latest").push()
                            docker.image("${DOCKER_HUB_REPO}/facebook-server:latest").push()
                        }
                    } catch (Exception e) {
                        echo "Failed to push to Docker Hub: ${e.getMessage()}"
                        throw e
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    try {
                        sh 'docker-compose --version'
                        sh 'docker-compose down'
                        sh 'docker-compose up --build -d'
                    } catch (Exception e) {
                        echo "Failed to deploy: ${e.getMessage()}"
                        throw e
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            sh 'docker-compose down'
        }
    }
}
