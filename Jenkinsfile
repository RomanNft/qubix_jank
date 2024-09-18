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
                    sh "docker build --no-cache -t roman2447/website:1.1 ."
                }
            }
        }

        stage('Push Combined Image') {
            steps {
                script {
                    // Push combined Docker image to Docker Hub
                    withCredentials([usernamePassword(credentialsId: 'DockerHub-Credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh '''
                        docker login -u $USERNAME -p $PASSWORD
                        docker push roman2447/website:1.1
                        '''
                    }
                }
            }
        }

        stage('Docker stop and remove previous container') {
            steps {
                echo "============= Stopping and removing previous container ================"
                sh '''
                docker stop my_container || true
                docker rm my_container || true
                '''
            }
        }

        stage('Docker run') {
            steps {
                echo "============= Starting server ================"
                sh '''
                docker run -d -p 80:80 --name my_container roman2447/website:1.1
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
