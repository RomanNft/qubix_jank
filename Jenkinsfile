pipeline {
    agent any
    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials-id'
    }
    stages {
        stage('Build') {
            steps {
                script {
                    // Build the Docker images
                    docker.build('qwqaz-migration', '-f Dockerfile_MIGRATION .')
                    docker.build('roman2447/facebook-server', '-f Dockerfile .')
                    docker.build('facebook-client', '-f Dockerfile-client .')
                }
            }
        }

        stage('Push') {
            steps {
                script {
                    // Push the Docker images to Docker Hub
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) {
                        docker.image('qwqaz-migration').push('latest')
                        docker.image('roman2447/facebook-server').push('latest')
                        docker.image('facebook-client').push('latest')
                    }
                }
            }
        }

        stage('Migrate') {
            steps {
                script {
                    // Run the migration container
                    docker.image('qwqaz-migration').inside {
                        sh './wait-for-postgres.sh'
                        sh 'dotnet ef database update'
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Deploy the Facebook server container
                    docker.image('roman2447/facebook-server').run('-d --name facebook-server')
                }
            }
        }

        stage('Start Frontend') {
            steps {
                script {
                    // Start the Facebook client container
                    docker.image('facebook-client').run('-d --name facebook-client')
                }
            }
        }
    }
    post {
        always {
            // Clean up Docker images after the build
            sh 'docker system prune -af'
        }
    }
}
