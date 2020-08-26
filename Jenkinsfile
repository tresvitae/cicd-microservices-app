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
                sh 'docker run -it --rm -d -p 8000:80 --name web webserver-app:dev'
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
        stage('Deploy on ECR') {
            steps {
                sh 'echo "publish"'
            }
        }
    }
    post {
        success {
            echo 'Do something when it is successful'
        }
        failure {
            sh 'docker container stop web'
            sh 'docker container prune -f'
            echo 'BUILD FAILED'
        }
    }
}