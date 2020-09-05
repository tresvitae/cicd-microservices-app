pipeline {
    environment {
        registry = 'tresvitae/webserver-app:v1'
        rolling_update = 'tresvitae/webserver-app:v1.1'
        ecr_repo = 'udacity-capstone:latest'
    }
    agent any
    stages {
        stage('Linting') {
            steps {
                sh 'tidy -q -e *.index'
            }
        }
        stage('Build the image') {
            steps {
                script {
                    docker.build registry 
                }
                //  + ':$BUILD_NUMBER'
                sh 'docker image ls'
                sh 'docker tag ' + registry + " " + ecr_repo
                //sh 'docker run -it --rm -d -p 8080:80 --name web ' + registry
                //sh 'docker container ls'
            }
        }
        stage('Security Aqua MicroScanner') {
            steps { 
                aquaMicroscanner imageName: 'alpine:latest', notCompliesCmd: 'exit 3', onDisallowed: 'fail', outputFormat: 'html'
            }
        }
        stage('Push to AWS ECR') {
            steps {
                script {
                    docker.withRegistry('https://998598315760.dkr.ecr.us-west-2.amazonaws.com/' + ecr_repo, 'ecr:us-west-2:aws-cred-ecr') {
                        docker.image('udacity-capstone').push('latest')
                    }
                }
            }
        }
        stage('Rolling update via AWS EKS') {
            steps {
                withAWS(credentials: 'aws-cred-ecr', region: 'us-west-2') {
                    sh '''
                        kubectl apply -f strategy/rolling-update.yaml
                        kubectl get all -n default
                        #//sh 'kubectl rollout status deployment default'
                    '''
                }
            }
        }
    }
    post {
        success {
            echo 'Webserver app pushed, and deployed to Amazon Web Service'
        }
        failure {
            //sh 'docker container stop web'
            sh 'docker container prune -f'
            sh 'docker image prune -af'
            echo 'BUILD FAILED'
        }
    }
}