pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials-id')
        GIT_REPO = 'https://github.com/RomanNft/faces2'
        IMAGE_CLIENT = 'roman2447/facebook-client:latest'
        IMAGE_SERVER = 'roman2447/facebook-server:latest'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: env.GIT_REPO]])
            }
        }

        stage('Check Credentials') {
            steps {
                script {
                    echo "Credentials found: ${DOCKERHUB_CREDENTIALS}"
                }
            }
        }

        stage('Build and Push Images') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'dockerhub-credentials-id', url: '']) {
                        sh "docker build -t ${IMAGE_CLIENT} ./facebook-client"
                        sh "docker push ${IMAGE_CLIENT}"

                        sh "docker build -t ${IMAGE_SERVER} ./facebook-server"
                        sh "docker push ${IMAGE_SERVER}"
                    }
                }
            }
        }

        stage('Run Migrations') {
            steps {
                script {
                    sh "docker-compose -f docker-compose.yaml up -d db"
                    sh "docker-compose -f docker-compose.yaml run --rm migration"
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                script {
                    sh "docker-compose -f docker-compose.yaml up -d"
                }
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed'
        }
        success {
            echo 'Pipeline succeeded'
        }
    }
}
