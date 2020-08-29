pipeline {
    environment {
        registry = 'tresvitae/webserver-app'
    }
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    docker.build registry + ':$BUILD_NUMBER'
                }
                sh 'docker image ls'
                sh 'docker run -it --rm -d -p 8000:80 --name web ' + registry + ':$BUILD_NUMBER'
                sh 'docker container ls'
            }
        }
        stage('Linting') {
            steps {
                sh 'tidy -q -e *.html'
            }
        }
        stage('Security Aqua MicroScanner') {
            steps { 
                aquaMicroscanner imageName: 'alpine:latest', notCompliesCmd: 'exit 3', onDisallowed: 'fail', outputFormat: 'html'
            }
        }
        stage('Change a tag of docker image') {
            steps {
                sh 'docker image tag ' + registry + ':$BUILD_NUMBER udacity-capstone:latest'
                sh 'docker image ls'
            }
        }
        stage('Push to AWS ECR') {
            steps {
                script {
                    docker.withRegistry('https://998598315760.dkr.ecr.us-west-2.amazonaws.com/udacity-capstone:latest', 'ecr:us-west-2:aws-cred-ecr') {
                        docker.image('udacity-capstone').push("latest")
                    }
                }
            }
        }
    }
    post {
        success {
            echo 'Docker image pushed, and deployed to Amazon ECR repository'
        }
        failure {
            sh 'docker container stop web'
            sh 'docker container prune -f'
            sh 'docker image prune -af'
            echo 'BUILD FAILED'
        }
    }
}