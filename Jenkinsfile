// Jenkinsfile

pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out the source code...'
                checkout scm
            }
        }

        stage('Setup and Build') {
            steps {
                echo 'Running setup script and building the project...'
                sh './setup.sh'
            }
        }

        stage('Run Docker Compose') {
            steps {
                echo 'Running Docker Compose...'
                sh 'docker-compose up -d --build'
            }
        }

        stage('Cleanup') {
            steps {
                echo 'Cleaning up...'
                sh 'docker-compose down'
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
        success {
            echo 'Pipeline succeeded.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
