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

        stage('Build and Start Containers') {
            steps {
                script {
                    // Build and start containers using docker-compose
                    sh "docker-compose -f facebook-server/docker-compose.yaml up --build -d"
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
