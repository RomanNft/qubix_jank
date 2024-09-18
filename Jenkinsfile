pipeline {
    agent {
        label 'my_service_credentials' // Замініть на потрібний лейбл агента
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
    }

    stages {
        stage("Checkout") {
            steps {
                echo 'Checking out code ...'
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: 'refs/heads/main']],
                    userRemoteConfigs: [[url: 'https://github.com/RomanNft/qwqaz.git']]
                ])
            }
        }

        stage("Create docker image") {
            steps {
                echo 'Creating docker image ...'
                // Використовуйте правильний шлях до Docker
                withEnv(["PATH+DOCKER=/usr/bin"]) { 
                    sh "docker build --no-cache -t roman2447/website:1.1 ."
                }
            }
        }

        stage("Docker login") {
            steps {
                echo "============= Docker login ================"
                withCredentials([usernamePassword(credentialsId: 'DockerHub-Credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh '''
                    docker login -u $USERNAME -p $PASSWORD
                    '''
                }
            }
        }

        stage("Docker push") {
            steps {
                echo "============= Pushing image ================"
                withEnv(["PATH+DOCKER=/usr/bin"]) { 
                    sh "docker push roman2447/website:1.1"
                }
            }
        }

        stage("Docker stop and remove previous container") {
            steps {
                echo "============= Stopping and removing previous container ================"
                withEnv(["PATH+DOCKER=/usr/bin"]) { 
                    sh '''
                    docker stop my_container || true
                    docker rm my_container || true
                    '''
                }
            }
        }

        stage("Docker run") {
            steps {
                echo "============= Starting server ================"
                withEnv(["PATH+DOCKER=/usr/bin"]) { 
                    sh '''
                    docker run -d -p 80:80 --name my_container roman2447/website:1.1
                    '''
                }
            }
        }
    }
}
