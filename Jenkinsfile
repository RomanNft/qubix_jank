pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/RomanNft/qwqaz.git'
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'my_service_', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh '''
                            echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                            if [ $? -eq 0 ]; then
                                echo "Docker login successful"
                                export DOCKER_LOGIN_SUCCESS=true
                            else
                                echo "Docker login failed"
                                export DOCKER_LOGIN_SUCCESS=false
                            fi
                        '''
                    }
                }
            }
        }

        stage('Build and Push facebook-client') {
            when {
                expression {
                    return env.DOCKER_LOGIN_SUCCESS == 'true'
                }
            }
            steps {
                script {
                    sh 'docker build -t roman2447/facebook-client:latest ./facebook-client'
                    sh 'docker push roman2447/facebook-client:latest'
                }
            }
        }

        stage('Build and Push facebook-server') {
            when {
                expression {
                    return env.DOCKER_LOGIN_SUCCESS == 'true'
                }
            }
            steps {
                script {
                    sh 'docker build -t roman2447/facebook-server:latest ./facebook-server'
                    sh 'docker push roman2447/facebook-server:latest'
                }
            }
        }
    }

    post {
        failure {
            echo 'The build failed. Please check the logs for details.'
        }
    }
}
