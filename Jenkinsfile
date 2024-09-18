pipeline {
    agent any // Використовуємо будь-який доступний агент

    environment {
        // Визначте змінні середовища для облікових даних DockerHub
        DOCKERHUB_CREDENTIALS = credentials('my_service_credentials')
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code ...'
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']], // Використовуйте підстановочний знак для імені гілки
                    userRemoteConfigs: [[url: 'https://github.com/RomanNft/qwqaz.git']]
                ])
            }
        }

        stage('Build Combined Image') {
            steps {
                script {
                    // Build combined Docker image
                    sh "docker build --no-cache -t ${DOCKERHUB_CREDENTIALS_USR}/facebook-server:latest -f facebook-server/Dockerfile ."
                    sh "docker build --no-cache -t ${DOCKERHUB_CREDENTIALS_USR}/facebook-client:latest -f facebook-client/Dockerfile ."
                }
            }
        }

        stage('Push Combined Image') {
            steps {
                script {
                    // Push combined Docker image to Docker Hub
                    withCredentials([usernamePassword(credentialsId: 'my_service_credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh '''
                        docker login -u $USERNAME -p $PASSWORD
                        docker push ${DOCKERHUB_CREDENTIALS_USR}/facebook-server:latest
                        docker push ${DOCKERHUB_CREDENTIALS_USR}/facebook-client:latest
                        '''
                    }
                }
            }
        }

        stage('Docker stop and remove previous container') {
            steps {
                echo "============= Stopping and removing previous container ================"
                sh '''
                docker stop qwqaz_facebook-server_1 || true
                docker rm qwqaz_facebook-server_1 || true
                docker stop qwqaz_facebook-client_1 || true
                docker rm qwqaz_facebook-client_1 || true
                '''
            }
        }

        stage('Docker run') {
            steps {
                echo "============= Starting server ================"
                sh '''
                docker-compose up -d
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline completed. Cleaning up..."
            // Додатково, приберіть ресурси тут
        }
        success {
            echo "Pipeline succeeded!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
