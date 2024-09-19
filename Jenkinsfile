pipeline {
    agent any

    environment {
        DOCKER_IMAGE_CLIENT = 'roman2447/facebook-client:latest'
        DOCKER_IMAGE_SERVER = 'roman2447/facebook-server:latest'
        DOCKER_IMAGE_MIGRATION = 'qwqaz_migration:latest'
    }

    stages {
        stage('Build Client') {
            steps {
                script {
                    sh 'docker build -t $DOCKER_IMAGE_CLIENT ./facebook-client'
                }
            }
        }

        stage('Build Server') {
            steps {
                script {
                    sh 'docker build -t $DOCKER_IMAGE_SERVER ./facebook-server'
                }
            }
        }

        stage('Build Migration') {
            steps {
                script {
                    sh 'docker build -t $DOCKER_IMAGE_MIGRATION -f Dockerfile_MIGRATION ./facebook-server'
                }
            }
        }

        stage('Run Docker Compose') {
            steps {
                script {
                    sh 'docker-compose up -d'
                }
            }
        }

        stage('Jenkins Setup') {
            steps {
                script {
                    sh 'docker run -d -p 8080:8080 -p 50000:50000 --name jenkins jenkins/jenkins:lts'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
