pipeline {
    agent any

    environment {
        // Docker Hub credentials ID, should be preconfigured in Jenkins (Manage Jenkins -> Credentials)
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
                // Check out the code from GitHub
                git url: 'https://github.com/RomanNft/qwqaz', branch: 'main'
            }
        }

        stage('Setup PostgreSQL Container') {
            steps {
                script {
                    // Start PostgreSQL container
                    def dbContainer = docker.run("-e POSTGRES_DB=${POSTGRES_DB} -p 5432:5432 --name postgres_db ${POSTGRES_IMAGE}", '--rm')
                    
                    // Wait for a few seconds to let PostgreSQL start
                    sleep time: 10, unit: 'SECONDS'
                }
            }
        }

        stage('Run Migrations') {
            steps {
                script {
                    // Run database migrations here
                    // Replace the command below with your migration command
                    sh 'docker exec postgres_db /path/to/migration/script.sh'
                }
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                script {
                    // Log in to Docker Hub
                    docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDENTIALS) {
                        // Build the client image
                        def clientImage = docker.build("${DOCKERHUB_IMAGE_CLIENT}:latest", './facebook-client')
                        clientImage.push('latest')

                        // Build the server image
                        def serverImage = docker.build("${DOCKERHUB_IMAGE_SERVER}:latest", './facebook-server')
                        serverImage.push('latest')
                    }
                }
            }
        }
    }

    post {
        cleanup {
            // Cleanup by stopping and removing the PostgreSQL container
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
