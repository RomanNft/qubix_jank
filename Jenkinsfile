properties([disableConcurrentBuilds()])

pipeline {
    agent {
        label ''
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
    }

    stages {
        stage("Checkout") {
            steps {
                echo 'Checking out code ...'
                git 'https://github.com/RomanNft/qwqaz.git'
            }
        }

        stage("Build docker images") {
            steps {
                echo 'Building Docker images for client and server ...'
                sh 'docker build -t roman2447/facebook-client:1.0 ./facebook-client'
                sh 'docker build -t roman2447/facebook-server:1.0 ./facebook-server'
            }
        }

        stage("Docker Login") {
            steps {
                echo 'Logging in to Docker Hub ...'
                withCredentials([usernamePassword(credentialsId: 'DockerHub-Credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh 'docker login -u $USERNAME -p $PASSWORD'
                }
            }
        }

        stage("Push images to Docker Hub") {
            steps {
                echo 'Pushing images to Docker Hub ...'
                sh 'docker push roman2447/facebook-client:1.0'
                sh 'docker push roman2447/facebook-server:1.0'
            }
        }

        stage("Stop and remove existing containers") {
            steps {
                echo 'Stopping and removing old containers ...'
                sh 'docker stop facebook-client || true'
                sh 'docker rm facebook-client || true'
                sh 'docker stop facebook-server || true'
                sh 'docker rm facebook-server || true'
            }
        }

        stage("Run containers") {
            steps {
                echo 'Starting new containers ...'
                sh 'docker run -d -p 5173:80 --name facebook-client roman2447/facebook-client:1.0'
                sh 'docker run -d -p 5181:80 --name facebook-server roman2447/facebook-server:1.0'
            }
        }
    }
}
