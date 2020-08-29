
# Udacity Capstone Project 

Develop a CI/CD pipeline for micro services applications with rolling deployment strategy. 

Project created on EC2 Instance with ami-0a634ae95e11c6f91 (us-west-2 region) - Linux Ubuntu 18.04 LTS.

First part of task is related to pushing the built Docker container to the AWS ECR.

Setup docker:
1. make docker
(May need to set non-root privileges for Docker container)

Setup Jenkins:
1. make jenkins-install jenkins-start
2. sudo cat /var/lib/jenkins/secrets/initialAdminPassword
3. copy&paste password to website "Getting Started" of Jenkins (port 8080)
4. click on Install suggested plugins
5. set Admin user
6. Save and Finish && Start using Jenkins
7. install additional packages: 
Blue Ocean
Config API for Blue Ocean
Events Api for Blue Ocean
Git Pipeline for Blue Ocean
GitHub Pipeline for Blue Ocean
Pipeline implementation for Blue Ocean
Blue Ocean Pipeline Editor
Display URL for Blue Ocean
Blue Ocean Executor Info

Pipeline: AWS Steps, Amazon ECR, CloudBees AWS Credentials Plugin

Aqua MicroScanner, Aqua Security Scanner

Docker, docker-build-step, CloudBees Docker Build and Publish plugin

8. Configure AquaMicroScanner in Jenkins
Add Docker installations in Global Tool Configuration in Jenkins
	Set Name (can be version of installed Docker in EC2, and Installation root: /usr/bin)
9. Setup GitHub project with Blue Ocean
10. Give Docker and Jenkins symbiotic permissions via command: sudo usermod -aG docker jenkins
11. Set up AWS credentials in Jenkins in “Manage Credentials” > icon "(global)" > "Add credentials"
12. Generate Access key ID and Secret acces key generated in your user in AWS console (Keep the credentials for futher process of installing AWS CLI)
13. Fill the credentials and set ID.

Configure AWS CLI and an authentication token 
1. In your EC2 instance, install and configure AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
2. Add permission ecr:GetAuthorizationToken API through an IAM policy n your working AWS account: AmazonEC2ContainerRegistryFullAccess
3. Run aws ecr get-login-password --region working_region | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com
(make red = aws_account_id, region)

Create AWS ECR repository:
1. Can be created in AWS Console, or via CLI:
aws ecr create-repository \
    --repository-name your-repo-name-aws:latest

Upgrade Jenkinsfile:
(a) In stage 'Change a tag of docker image', edit line:
sh 'docker image tag ' + registry + ':$BUILD_NUMBER your-repo-name-aws:latest'

(b) In stage 'Deploy to AWS ECR', add account ID, region, and repo name:
docker.withRegistry('https://aws_account_id.dkr.ecr.region.amazonaws.com/your-repo-name-aws:latest, 'ecr:region:aws-credential-id') {
                        docker.image('your-repo-name-aws').push("latest")

(make red = aws_account_id, region, your-repo-name-aws, aws-credential-id)

To built pipeline successfully, use 'make tidy' to pass the Linting stage.

Web app is deployed on :8000


Second part of the Project is related to deploy these Docker container to a small Kubernetes cluster as rolling update deployment strategy, where Version B is gradually rolled out succeeding verion A. Suitable for smal bug fixes.

Create AWS EKS Cluster and Node group
1. 