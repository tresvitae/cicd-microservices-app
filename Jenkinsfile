pipeline {
    environment {
        registry = 'tresvitae/webserver-app:v1' //First repo
        rolling_update = 'tresvitae/webserver-app:v2'
        ecr_repo = 'udacity-capstone:latest'
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
                script {
                    docker.build rolling_update
                }
                //  + ':$BUILD_NUMBER'
                sh 'docker image ls'
                sh 'docker tag ' + rolling_update + " " + ecr_repo
                //sh 'docker run -it --rm -d -p 8000:8000 --name web ' + registry
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
                //withAWS(region:'us-west-2', credentials:'aws-cred-ecr') {
                    //sh 'aws eks --region us-west-2 update-kubeconfig --name p-cluster'
                    //sh 'kubectl config use-context arn:aws:eks:us-west-2:998598315760:cluster/p-cluster'
                    sh 'kubectl apply -f strategy/rolling-update.yaml'
                    sh 'kubectl get all -n default'
                    //sh 'kubectl rollout status deployment default'
                //}
            }
        }
        stage('Clearning a docker container') {
            steps {
                sh 'docker container prune -f'
                sh 'docker image prune -af'
            }
        }
    }
}