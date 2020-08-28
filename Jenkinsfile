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
        stage('deployed on ECR') {
            steps {
                script {
                    docker.withRegistry('https://998598315760.dkr.ecr.us-west-2.amazonaws.com/udacity-capstone:latest', 'ecr:us-west-2:aws-cred-ecr') {
                    sh 'docker tag ' + registry + ':$BUILD_NUMBER 998598315760.dkr.ecr.us-west-2.amazonaws.com/udacity-capstone:latest'
                }
            }
        }
    }
    }
    post {
        success {
            echo 'Docker container deployed on Amazon ECR repository'
        }
        failure {
            sh 'docker container stop web'
            sh 'docker container prune -f'
            sh 'docker image prune --filter "until=24h" -f'
            echo 'BUILD FAILED'
        }
    }
}