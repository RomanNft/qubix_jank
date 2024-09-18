pipeline {
    agent any
    stages {
        stage("docker login") {
            steps {
                echo " ============== docker login =================="
                withCredentials([usernamePassword(credentialsId: 'your-docker-hub-credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    script {
                        def loginResult = sh(script: "docker login -u $USERNAME -p $PASSWORD", returnStatus: true)
                        if (loginResult != 0) {
                            error "Failed to log in to Docker Hub. Exit code: ${loginResult}"
                        }
                    }
                }
                echo " ============== docker login completed =================="
            }
        }
        stage('Build and Push facebook-client') {
            steps {
                echo " ============== docker facebook-client =================="
                dir('facebook-client') {
                    sh "docker build -t roman2447/facebook-client:latest ."
                    sh "docker push roman2447/facebook-client:latest"
                }
                echo " ============== docker facebook-client completed =================="
            }
        }
        stage('Build and Push facebook-server') {
            steps {
                echo " ============== docker facebook-server =================="
                dir('facebook-server') {
                    sh "docker build -t roman2447/facebook-server:latest ."
                    sh "docker push roman2447/facebook-server:latest"
                }
                echo " ============== docker facebook-server completed =================="
            }
        }
        stage('Build and Push jenkins') {
            steps {
                echo " ============== docker jenkins =================="
                sh "docker build -t roman2447/jenkins:latest ."
                sh "docker push roman2447/jenkins:latest"
                echo " ============== docker jenkins completed =================="
            }
        }
        stage('Run setup script') {
            steps {
                echo " ============== Running setup script =================="
                sh "./setup.sh"
                echo " ============== Setup script completed =================="
            }
        }
    }
}
