pipeline {
    agent any
    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials-id'
    }
    stages {
        stage('Build') {
            steps {
                script {
                    docker.build('qwqaz-migration', '-f Dockerfile_MIGRATION .')
                    docker.build('roman2447/facebook-server', '-f Dockerfile .')
                    docker.build('facebook-client', '-f Dockerfile-client .')
                }
            }
        }

        stage('Push') {
            steps {
                script {
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
                    docker.image('roman2447/facebook-server').run('-d --name facebook-server')
                }
            }
        }

        stage('Start Frontend') {
            steps {
                script {
                    docker.image('facebook-client').run('-d --name facebook-client')
                }
            }
        }
    }
    post {
        always {
            sh 'docker system prune -af'
        }
    }
}
