pipeline {
    agent any

    environment {
        // Docker Hub credentials ID, це повинно бути попередньо налаштоване в Jenkins (Manage Jenkins -> Credentials)
        DOCKERHUB_CREDENTIALS = 'my_service_'
        DOCKERHUB_USERNAME = 'roman2447'
        DOCKERHUB_IMAGE_CLIENT = 'roman2447/facebook-client'
        DOCKERHUB_IMAGE_SERVER = 'roman2447/facebook-server'
    }

    stages {
        stage('Checkout') {
            steps {
                // Завантаження коду з GitHub
                git url: 'https://github.com/RomanNft/qwqaz', branch: 'main'
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                script {
                    // Логін в Docker Hub
                    docker.withRegistry('https://index.docker.io/v1/', "$DOCKERHUB_CREDENTIALS") {

                        // Побудова клієнтського образу
                        def clientImage = docker.build("$DOCKERHUB_IMAGE_CLIENT:latest", './facebook-client')
                        clientImage.push('latest')

                        // Побудова серверного образу
                        def serverImage = docker.build("$DOCKERHUB_IMAGE_SERVER:latest", './facebook-server')
                        serverImage.push('latest')
                    }
                }
            }
        }

        stage('Run Services with Docker Compose') {
            steps {
                // Запуск сервісів за допомогою docker-compose
                dir('qwqaz') {
                    sh 'docker-compose up -d --build'
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed. Check the logs for more details.'
        }
    }
}
