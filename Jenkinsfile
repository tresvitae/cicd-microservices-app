pipeline { 
    agent any 
    stages {
        stage('Build') { 
            steps { 
                sh 'docker build -t webserver:dev nginx-app/.' 
                sh 'docker run -it --rm -d -p 8000:80 --name web webserver:dev'
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
    post {
        success {
            echo 'Do something when it is successful'
            bitbucketStatusNotify(buildState: 'SUCCESSFUL')
        }
        failure {
            echo 'Do something when it is failed'
            bitbucketStatusNotify(buildState: 'FAILED')
        }
    }
}