pipeline {
    agent any

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Run Setup Script') {
            steps {
                script {
                    sh '''
                    # Перехід до директорії з проектом
                    cd /home/roman/push

                    # Виконання скрипту setup.sh
                    bash ./setup.sh
                    '''
                }
            }
        }

        stage('Check Container Status') {
            steps {
                script {
                    sh '''
                    # Перевірка статусу контейнерів
                    docker-compose ps
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Pipeline succeeded.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
