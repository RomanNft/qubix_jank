pipeline {
    agent any
    
    stages {
        stage('Clone repository') {
            steps {
                // Clone the repository
                git branch: 'main', url: 'https://github.com/RomanNft/qwqaz'
            }
        }

        stage('Build Docker Containers') {
            steps {
                withCredentials([string(credentialsId: 'sudo_password', variable: 'SUDO_PASS')]) {
                    sh """
                    echo $SUDO_PASS | sudo -S bash setup.sh
                    """
                }
            }
        }

        stage('Run Tests') {
            steps {
                // Run tests if applicable
                sh 'docker-compose up -d'
            }
        }

        stage('Push Docker Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'my_service_', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker-compose push
                    """
                }
            }
        }

        stage('Clean Up') {
            steps {
                // Clean up running containers
                sh 'docker-compose down'
            }
        }
    }
}
