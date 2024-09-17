// Groovy Jenkinsfile

properties([disableConcurrentBuilds()])

pipeline {
    agent {
        label 'docker'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
    }

    stages {
        stage("Checkout") {
            steps {
                echo 'Checking out the source code ...'
                checkout scm
            }
        }

        stage("Build and Push Docker Images") {
            steps {
                echo 'Building and pushing docker images ...'
                script {
                    withCredentials([usernamePassword(credentialsId: 'DockerHub-Credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh '''
                        docker login -u $USERNAME -p $PASSWORD
                        docker-compose build
                        docker-compose push
                        '''
                    }
                }
            }
        }

        stage("Deploy with Docker Compose") {
            steps {
                echo 'Deploying with docker-compose ...'
                sh '''
                docker-compose down || true
                docker-compose up -d
                '''
            }
        }
    }

    post {
        always {
            echo 'Cleaning up ...'
            sh 'docker-compose down || true'
        }
    }
}
