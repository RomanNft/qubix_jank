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
                    script {
                        // Create a temporary file to store the sudo password
                        def tempFile = "${env.WORKSPACE}/sudo_password.txt"
                        writeFile file: tempFile, text: SUDO_PASS
                        
                        // Use the temporary file to pass the sudo password
                        sh """
                        sudo -S bash setup.sh < ${tempFile}
                        """
                        
                        // Clean up the temporary file
                        sh "rm -f ${tempFile}"
                    }
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
