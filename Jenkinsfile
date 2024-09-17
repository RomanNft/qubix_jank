pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('70d58f4e-0207-4fe0-86a8-dfaf74688d05')  // Облікові дані Docker Hub
    }

    stages {
        stage('Checkout') {
            steps {
                // Клонування репозиторію
                git 'https://github.com/RomanNft/qwqaz.git'
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    // Створюємо Docker образи для клієнта та сервера
                    sh 'docker-compose -f docker-compose.yaml build'
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    // Логін в Docker Hub
                    sh "echo $DOCKER_HUB_CREDENTIALS_PSW | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin"

                    // Пуш Docker образів на Docker Hub
                    sh 'docker tag facebook-client:latest roman2447/facebook-client:latest'
                    sh 'docker tag facebook-server:latest roman2447/facebook-server:latest'

                    sh 'docker push roman2447/facebook-client:latest'
                    sh 'docker push roman2447/facebook-server:latest'
                }
            }
        }

        stage('Run Docker Compose') {
            steps {
                script {
                    // Запуск сервісів за допомогою Docker Compose
                    sh 'docker-compose -f docker-compose.yaml up -d'
                }
            }
        }
    }

    post {
        always {
            // Очищення контейнерів та мереж Docker після виконання
            sh 'docker-compose -f docker-compose.yaml down'
        }
        success {
            echo 'Deployment was successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}
