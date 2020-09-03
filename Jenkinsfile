pipeline {
    environment {
        registry = 'udacity-capstone:$BUILD_NUMBER'
    }
    agent any
    stages {
        stage('Linting') {
            steps {
                sh 'tidy -q -e *.html'
            }
        }
        stage('Build the image') {
            steps {
                sh 'docker build -t ' + registry + " ."
                sh 'docker image ls'
                //sh 'docker run -it --rm -d -p 8080:8080 --name web ' + registry
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
                    docker.withRegistry('https://998598315760.dkr.ecr.us-west-2.amazonaws.com/' + registry, 'ecr:us-west-2:aws-cred-ecr') {
                        docker.image('udacity-capstone').push($BUILD_NUMBER)
                    }
                }
            }
        }
        stage('Rolling update via AWS ECS') {
            steps {
                withAWS(credentials: 'aws-cred-ecr', region: 'us-west-2') {
                    sh '''
                        aws eks --region us-west-2 update-kubeconfig --name dev-cluster
                        #//sh 'kubectl config set-context $(kubectl config current-context) --namespace dev-cluster'
                        kubectl config use-context arn:aws:eks:us-west-2:998598315760:cluster/dev-cluster
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