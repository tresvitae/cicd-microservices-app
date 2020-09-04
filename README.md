
# Udacity Capstone Project 

## Project Overview

Develop a CI/CD pipeline for micro services applications with rolling update deployment strategy. 

Project created on EC2 Instance with ami-0a634ae95e11c6f91 (us-west-2 region) - Linux Ubuntu 18.04 LTS.

Preconfiguration:
1. Build EC2 instance in AWS
2. clone the repository  
  
### First part of task is related to pushing the built Docker container to the AWS ECR  

Setup docker:
1. `make docker-install`
* May need to set non-root privileges for Docker container
* and set sudo apt-get install build-essential
2. Check status `make docker-check`
If status in another then active, run `make docker-start`  

Setup Jenkins:
1. `make jenkins-install`
2. Edit the /etc/default/jenkins  to replace the port in HTTP_PORT and --httpPort in JENKINS_ARGS to 8000
3. `sudo service jenkins restart` or may to restart instance
4. `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
5. Copy&paste password to website "Getting Started" of Jenkins
6. Click on Install suggested plugins
7. Set Admin user
8. Save and Finish && Start using Jenkins
9. Install additional packages in Manage Jenkins>Manage Plugins: 
Blue Ocean  
Config API for Blue Ocean  
Events Api for Blue Ocean  
Git Pipeline for Blue Ocean  
GitHub Pipeline for Blue Ocean  
Pipeline implementation for Blue Ocean  
Blue Ocean Pipeline Editor  
Display URL for Blue Ocean  
Blue Ocean Executor Info  
Pipeline: AWS Steps  
Amazon ECR  
CloudBees AWS Credentials Plugin  
AWS Global Configuration  
Amazon Elastic Container Service (ECS)  
Aqua MicroScanner  
Aqua Security Scanner  
Docker  
docker-build-step  
CloudBees Docker Build and Publish  

10. Configure AquaMicroScanner in Jenkins
11. Add Docker installations in Global Tool Configuration in Jenkins. Set Name (can be version of installed Docker in EC2, and Installation root: /usr/bin)
12. Setup GitHub project with Blue Ocean
13. Give Docker and Jenkins symbiotic permissions via command: `sudo usermod -aG docker jenkins`
14. Set up AWS credentials in Jenkins in “Manage Credentials” > icon "(global)" > "Add credentials"
15. Generate Access key ID and Secret acces key generated in your user in AWS console (Keep the credentials for futher process of installing AWS CLI)
16. Fill the credentials and set ID  

Configure AWS CLI and set permission for AWS ECR and EKS to your user
1. In your EC2 instance, install and configure AWS CLI `make aws-cli` or follow the steps in [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
2. Add permission `eks:CreateCluster` and `ecr:GetAuthorizationToken` API through an IAM policy n your working AWS account: 
* AmazonEC2ContainerRegistryFullAccess
* AmazonEKSClusterPolicy
* AmazonEKSServicePolicy
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
        registry = 'udacity-capstone:$BUILD_NUMBER'
```  

* In stage 'Deploy to AWS ECR', add account ID, and region:
```bash
docker.withRegistry('https://(aws_account_id).dkr.ecr.(region).amazonaws.com/' + registry, 'ecr:region:(aws-credential-id)) { docker.image(your-repo-name-aws).push($BUILD_NUMBER) }
```  

### Second part of the Project is related to deploy these Docker container to a small Kubernetes cluster as rolling update deployment strategy, where Version B is gradually rolled out succeeding verion A. Suitable for smal bug fixes  

Install eksctl and kubectl in EC2
1. `make aws-eksctl` or follow the steps in [AWS EKSCTL](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)
2. `make aws-kubectl` or follow the steps in [AWS KUBECTL](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)  

Create AWS EKS Cluster and Node group
1. Use CloudFormationt scrip to create EKS Cluster:
To deploy this infrastructure there is a helper script included in the repository. It can be used like this: 
```bash
aws cloudformation create-stack --stack-name web-cluster --template-body file://strategy/eks-cluster.yaml --parameters file://strategy/eks-cluster-param.json --region=us-west-2`
aws cloudformation create-stack --stack-name web-node --template-body file://strategy/eks-nodegroup.yaml --parameters file://strategy/eks-nodegroup-param.json --region=us-west-2
```  
2. Alternativly, can be created in AWS Console, or via CLI:
```bash
eksctl create cluster --name web-cluster --version 1.17 --region us-west-2 --nodegroup-name web-node --node-type t2.micro --nodes 3 --nodes-min 1 --nodes-max 4 --managed
```  
Also, you need to give necessary policies to your user (see scripts/eksctl-policy.yml)
3. Build the image of web-app
* `docker build -t udacity-capstone:latest .`
4. (optional) Test the container:
* `docker run -it --rm -d -p 8080:8080 udacity-capstone:latest`
* `curl http://localhost:8080`
5. Build Service and Deployment of web-server in kubernetes cluster
* `aws eks --region us-west-2 update-kubeconfig --name web-cluster` or `kubectl config set-context $(kubectl config current-context) --namespace web-cluster`
* `kubectl config use-context arn:aws:eks:us-west-2:998598315760:cluster/web-cluster` (Change to your region and aws id)
* `kubectl create deployment web-app --image=udacity-capstone:latest`
6. set number of replicas to 3 and add HorizontalPodAutoscaler resource for your Deployment
`kubectl scale deployment web-app --replicas=3`
`kubectl autoscale deployment web-app --cpu-percent=80 --min=1 --max=4`
7. To see created Pods run `kubectl get pods`
8. Expose the web-server to the Internet
`kubectl expose deployment web-app --name=web-app-service --type=LoadBalancer --port 80 --target-port 8080`
9. To see exposed IP, run `kubectl get service`

4. Edit Jenkinsfile, in stage 'Rolling update via AWS EKS', set your credentials.
4. Edit service/rolling-update.yaml file, by adding your ECR url of deployed image.  

  
## Implementation the Project:  

Web app is deployed on localhost:8080  


To built pipeline successfully, use 'make tidy' to pass the Linting stage.  

