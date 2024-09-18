pipeline {
    agent {
        label 'my_service_credentials' // Replace with the correct label
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
                sh "docker build --no-cache -t roman2447/website:1.1 ."
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
                sh "docker push roman2447/website:1.1"
            }
        }

        stage("Docker stop and remove previous container") {
            steps {
                echo "============= Stopping and removing previous container ================"
                sh '''
                docker stop my_container || true
                docker rm my_container || true
                '''
            }
        }

        stage("Docker run") {
            steps {
                echo "============= Starting server ================"
                sh '''
                docker run -d -p 80:80 --name my_container roman2447/website:1.1
                '''
            }
        }
    }
}
