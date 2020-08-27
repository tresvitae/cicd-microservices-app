
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

Pipeline: AWS Steps, Amazon ECR

Aqua MicroScanner, Aqua Security Scanner

Docker, docker-build-step

8. Configure AquaMicroScanner in Jenkins
Add Docker installations in Global Tool Configuration in Jenkins
	Set Name (can be version of installed Docker in EC2, and Installation root: /usr/bin)
9. Setup GitHub project with Blue Ocean
10. Give Docker and Jenkins symbiotic permissions via command: sudo usermod -aG docker jenkins

Configure AWS CLI and an authentication token 
1. In your EC2 instance, install and configure AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
2. Add permission ecr:GetAuthorizationToken API through an IAM policy n your working AWS account: AmazonEC2ContainerRegistryFullAccess
3. Run aws ecr get-login-password --region working_region | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com
(make red = aws_account_id, region)
4. Now, you need to edit Jenkinsfile:

(a) Tag your image so you can push the image to your repository:
docker tag tresvitae/webserver-app:$BUILD_NUMBER aws_account_id.dkr.ecr.region.amazonaws.com/your-repo-name-aws:latest
(b) Push this image to your created AWS repository:
docker push aws_account_id.dkr.ecr.region.amazonaws.com/your-repo-name-aws:latest
(make red = aws_account_id, region, your-repo-name-aws)


To built pipeline successfully, use 'make tidy' to pass the Linting stage.


Second part of the Project is related to deploy these Docker container to a small Kubernetes cluster.
