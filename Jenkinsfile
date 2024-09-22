pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'my_service_'
        DOCKERHUB_USERNAME = 'roman2447'
        DOCKERHUB_IMAGE_CLIENT = 'roman2447/facebook-client'
        DOCKERHUB_IMAGE_SERVER = 'roman2447/facebook-server'
        POSTGRES_IMAGE = 'postgres:latest'
        POSTGRES_DB = 'myDB'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/RomanNft/qwqaz', branch: 'main'
            }
        }

        stage('Setup PostgreSQL Container') {
            steps {
                script {
                    def dbContainer = docker.image(POSTGRES_IMAGE).run("-e POSTGRES_DB=${POSTGRES_DB} -p 5432:5432 --name postgres_db")
                    sleep time: 10, unit: 'SECONDS' // Ensure PostgreSQL has time to start
                }
            }
        }

        stage('Run Migrations') {
            steps {
                script {
                    // Modify this command based on your migration script path
                    sh 'docker exec postgres_db /path/to/migration/script.sh'
                }
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDENTIALS) {
                        def clientImage = docker.build("${DOCKERHUB_IMAGE_CLIENT}:latest", './facebook-client')
                        clientImage.push('latest')

                        def serverImage = docker.build("${DOCKERHUB_IMAGE_SERVER}:latest", './facebook-server')
                        serverImage.push('latest')
                    }
                }
            }
        }
    }

    post {
        cleanup {
            sh 'docker stop postgres_db || true'
            sh 'docker rm postgres_db || true'
        }
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed. Check the logs for more details.'
        }
    }
}
