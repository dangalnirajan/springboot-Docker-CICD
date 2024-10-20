pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = 'DockerhubCredentials'
        DOCKER_HUB_REPO = 'nirajandangal'
    }

    tools {
        maven 'Maven_3.6.3'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/dangalnirajan/springboot-Docker-CICD']])
            }
        }

        stage('Build Maven') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
        }

        stage('Build and Deploy Docker Containers') {
            steps {
                script {
                    sh 'docker-compose down'
                    sh 'docker-compose build'  
                    sh 'docker-compose up -d'
                }
            }
        }

        stage('Push Docker Images to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_HUB_CREDENTIALS) {
                        sh 'docker-compose push'
                    }
                }
            }
        }
    }
}
