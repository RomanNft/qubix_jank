pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'my_service_'  // Заміни на свій ID облікових даних Docker Hub у Jenkins
        DOCKER_USERNAME = 'roman2447'  // Заміни на свій Docker Hub логін
        DOCKER_IMAGE_CLIENT = 'roman2447/facebook-client'
        DOCKER_IMAGE_SERVER = 'roman2447/facebook-server'
    }

    stages {
        stage('Checkout') {
            steps {
                // Клонування репозиторію
                git 'https://github.com/RomanNft/qwqaz.git'
            }
        }
        
        stage('Build and Push Client Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', DOCKER_CREDENTIALS_ID) {
                        sh 'docker-compose build facebook-client'
                        sh 'docker tag ${DOCKER_IMAGE_CLIENT}:latest ${DOCKER_IMAGE_CLIENT}:${BUILD_NUMBER}'
                        sh 'docker push ${DOCKER_IMAGE_CLIENT}:latest'
                        sh 'docker push ${DOCKER_IMAGE_CLIENT}:${BUILD_NUMBER}'
                    }
                }
            }
        }
        
        stage('Build and Push Server Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', DOCKER_CREDENTIALS_ID) {
                        sh 'docker-compose build facebook-server'
                        sh 'docker tag ${DOCKER_IMAGE_SERVER}:latest ${DOCKER_IMAGE_SERVER}:${BUILD_NUMBER}'
                        sh 'docker push ${DOCKER_IMAGE_SERVER}:latest'
                        sh 'docker push ${DOCKER_IMAGE_SERVER}:${BUILD_NUMBER}'
                    }
                }
            }
        }

        stage('Run Services') {
            steps {
                // Запуск Docker Compose сервісів
                sh 'docker-compose up -d'
            }
        }
    }

    post {
        always {
            // Архівування логів або важливих артефактів
            archiveArtifacts artifacts: '**/target/*.log', allowEmptyArchive: true
        }
    }
}
