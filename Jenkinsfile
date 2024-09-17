pipeline {
    agent any

    options {
        skipDefaultCheckout()
        disableConcurrentBuilds()
    }

    stages {
        stage('Build and Push') {
            steps {
                dir('facebook-client') {
                    sh 'docker build -t roman2447/facebook-client:latest .'
                    sh 'docker push roman2447/facebook-client:latest'
                }
                dir('facebook-server') {
                    sh 'docker build -t roman2447/facebook-server:latest .'
                    sh 'docker push roman2447/facebook-server:latest'
                }
            }
        }

        stage('Migration') {
            steps {
                dir('facebook-server') {
                    sh 'docker build -f Dockerfile_MIGRATION -t roman2447/facebook-server-migration:latest .'
                    sh 'docker push roman2447/facebook-server-migration:latest'
                }
            }
        }

        stage('Setup') {
            steps {
                sh './setup.sh'
            }
        }

        stage('Compose Up') {
            steps {
                sh 'docker-compose up --build'
            }
        }
    }
}
