
# Udacity Capstone Project 

## Project Overview

Develop a CI/CD pipeline for micro services applications with rolling update deployment strategy. 

Project created on EC2 Instance with ami-0a634ae95e11c6f91 (us-west-2 region) - Linux Ubuntu 18.04 LTS.

Preconfiguration:
1. Build EC2 instance in AWS with necessary IAM Policy of EC2, VPC, EKS, and CloudFormation services.
2. Clone the repository  
To avoid all installation and permission configuration of jenkins, docker, aws cli, eksctl, and kubectl, add `ec2-setup.sh` file to User Data in a process of configuration a EC2 Instance. Check if all has been installed successfully:  
```bash
docker --version
aws --version
eksctl version
kubectl version --short --client
java -version
docker images # Without sudo privileges. If not, run sudo chmod 666 /var/run/docker.sock
```  

### First part of task is related to pushing the built Docker container to the AWS ECR  

Setup docker:
1. `make docker-install`
* May need to set non-root privileges for Docker container
* and set sudo apt-get install build-essential
2. Check status `make docker-check`
If status in another then active, run `make docker-start`  

Setup Jenkins:
1. `make jenkins-install`
2. `sudo service jenkins restart`
3. `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
4. Copy&paste password to website "Getting Started" of Jenkins
5. Click on Install suggested plugins
6. Set Admin user
7. Save and Finish && Start using Jenkins
8. Install additional packages in Manage Jenkins>Manage Plugins: 
Blue Ocean   
Git Pipeline for Blue Ocean  
GitHub Pipeline for Blue Ocean  
Pipeline implementation for Blue Ocean  
Blue Ocean Pipeline Editor  
Blue Ocean Executor Info  
Pipeline: AWS Steps  
Amazon ECR  
Aqua MicroScanner  
Docker  
docker-build-step  
CloudBees Docker Build and Publish  

10. Configure AquaMicroScanner in Jenkins
11. Add Docker installations in Global Tool Configuration in Jenkins. Set Name (can be version of installed Docker in EC2, and Installation root: /usr/bin)
12. Give Docker and Jenkins symbiotic permissions via command: `sudo usermod -aG docker jenkins`
13. Set up AWS credentials in Jenkins in “Manage Credentials” > icon "(global)" > "Add credentials"
14. Generate Access key ID and Secret acces key generated in your user in AWS console (Keep the credentials for futher process of installing AWS CLI)
15. Fill the credentials and set ID  

Configure AWS CLI and set permission for AWS ECR and EKS to your user
1. In your EC2 instance, install and configure AWS CLI `make aws-cli` or follow the steps in [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
2. Add permission an IAM policy in your jenkins-working Instance: 
* AmazonEC2ContainerRegistryFullAccess
* AmazonEKSClusterPolicy
* AmazonEKSServicePolicy
* AmazonEKSWorkerNodePolicy
* AWSCloudFormationFullAccess
* IAMFullAccess  

Create AWS ECR repository:
Can be created in AWS Console, or via CLI:
```bash
aws ecr create-repository --repository-name (your-repo-name-aws):latest
```  

Retrieve an authentication token and authenticate your Docker client to your registry:
```bash
aws ecr get-login-password --region (working_region) | docker login --username AWS --password-stdin (aws_account_id).dkr.ecr.(region).amazonaws.com
```  

Edit Jenkinsfile:
* Change enviroment's registory to your created name:
```bash
        registry = 'tresvitae/webservar-app:v1'
        rolling_update = 'tresvitae/webserver-app:v2'
        ecr_repo = 'udacity-capstone:latest'
```  

* In stage 'Deploy to AWS ECR', add account ID, and region:
```bash
docker.withRegistry('https://(aws_account_id).dkr.ecr.(region).amazonaws.com/' + registry, 'ecr:region:(aws-credential-id)) { docker.image(your-repo-name-aws).push($BUILD_NUMBER) }
```  

### Second part of the Project is related to deploy these Docker container to a small Kubernetes cluster as rolling update deployment strategy, where Version B is gradually rolled out succeeding verion A. Suitable for smal bug fixes  

Install eksctl and kubectl in EC2
1. `make aws-eksctl` or follow the steps in [AWS EKSCTL](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)
2. `make aws-kubectl` or follow the steps in [AWS KUBECTL](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)  

Set Docker CLI clinet: `docker login --username your_name --password your_password`. Thanks to that you will have access to pull image to Kubernetes.

Build Service and Deployment of web-server on independent stage in Jenkins Pipeline to perform kubernetes cluster:
* `aws eks --region us-west-2 update-kubeconfig --name web-cluster`

Create AWS EKS Cluster and Node group
1. Use CloudFormationt scrip to create EKS Cluster:
To deploy this infrastructure there is a helper script included in the repository. It can be used like this: 
```bash
aws cloudformation create-stack --stack-name web-cluster --template-body file://strategy/eks-cluster.yaml --parameters file://strategy/eks-cluster-param.json --region=us-west-2
aws cloudformation create-stack --stack-name web-node --template-body file://strategy/eks-nodegroup.yaml --parameters file://strategy/eks-nodegroup-param.json --region=us-west-2
```  
2. Alternativly, can be created in AWS Console, or via CLI:
```bash
eksctl create cluster --name web-cluster --version 1.17 --region us-west-2 --nodegroup-name web-node --node-type t2.micro --nodes 3 --nodes-min 1 --nodes-max 4 --managed
```  
### Can ignore bellow steps and run Jenkins pipeline to setup webserver automatically. Thanks to kubectl apply command can perform a infrastructure.   
You can implement kuberentes cluster via CLI:
1. Build the image of web-app
* `docker build -t tresvitae/webserver-app:v1 .`
2. Build Service and Deployment of web-server in Jenkins Pipeline to perform kubernetes cluster
* `aws eks --region us-west-2 update-kubeconfig --name web-cluster`
* `kubectl create deployment web-app --image=udacity-capstone:latest`
3. Set number of replicas to 3 and add HorizontalPodAutoscaler resource for your Deployment
`kubectl scale deployment web-app --replicas=3`
`kubectl autoscale deployment web-app --cpu-percent=80 --min=1 --max=4`
4. To see created Pods run `kubectl get pods`
5. Expose the web-server to the Internet
`kubectl expose deployment web-app --name=web-app-service --type=LoadBalancer --port 80 --target-port 30000`
6. To see exposed IP, run `kubectl get service`  
7. Run: `kubectl apply -f strategy/deployment.yaml`  
  
    
Finally: edit Jenkinsfile, in stage 'Rolling update via AWS EKS', set your credentials.
Also, edit service/rolling-update.yaml file, by adding your ECR url of deployed image.  
  
## Implementation the Project:  
Setup GitHub project with Blue Ocean. You should see resoult on website - check exposed IP address.
When you perform rolling update via Jenkins pipeline, performn new version of tagname of your docker image.  


Web app is deployed on http://af3fcdb39ab18458a87ea0bbd5d3e63f-1099063542.us-west-2.elb.amazonaws.com/git ad  


To built pipeline successfully, use 'make tidy' to pass the Linting stage.  

