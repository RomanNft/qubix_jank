pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh '/usr/local/bin/docker-compose build'
            }
        }
        stage('Test') {
            steps {
                sh '/usr/local/bin/docker-compose test'
            }
        }
        stage('Deploy') {
            steps {
                sh '/usr/local/bin/docker-compose deploy'
            }
        }
    }
}

    stages {
        stage('Build') {
            steps {
                sh 'docker-compose build'
            }
        }
        stage('Test') {
            steps {
                sh 'docker-compose up -d db'
                sh 'docker-compose exec db psql -U postgres -c "CREATE DATABASE facebook;"'
                sh 'docker-compose exec db psql -U postgres -d facebook -c "CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR(255));"'
                sh 'docker-compose up -d facebook-server'
                sh 'docker-compose exec facebook-server dotnet test'
                sh 'docker-compose exec facebook-client npm run test'
            }
        }
        stage('Deploy') {
            steps {
                sh 'docker-compose push'
                sh 'docker-compose up -d'
            }
        }
    }
}
