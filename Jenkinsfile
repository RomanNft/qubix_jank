pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'roman2447'
        DOCKER_HUB_CREDENTIALS = 'my_service_credentials'
    }

    stages {
        stage('Checkout') {
            steps {
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
    }
}
