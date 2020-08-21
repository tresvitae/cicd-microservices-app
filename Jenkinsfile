pipeline { 
    agent any 
    stages {
        stage('Build') { 
            steps { 
                sh 'docker build -t webserver:dev nginx-app/.' 
            }
            agent {
                docker { image 'webserver:dev' }
            }
        }
        stage('Linting'){
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
}