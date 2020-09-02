jenkins-install:
	sudo apt install -y openjdk-8-jdk
	wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
	sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
	sudo apt-get update
	sudo apt-get install -y jenkins
	sudo usermod -a -G docker jenkins

jenkins-start:
	sudo systemctl start jenkins
	sudo systemctl enable jenkins
	sudo systemctl status jenkins

jenkins: jenkins-install jenkins-start

tidy:
	sudo apt install -y tidy

docker-install:
	sudo apt-get update
	sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo apt install docker.io -y
	sudo chmod 666 /var/run/docker.sock
	chkconfig docker on

docker-check:
	docker --version
	sudo systemctl status docker

docker-start:
	sudo systemctl start docker
	sudo systemctl start docker

aws-cli:
	sudo apt install unzip -y
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	sudo ./aws/install
	aws --version

aws-eksctl:
	curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
	sudo mv /tmp/eksctl /usr/local/bin
	eksctl version

aws-kubectl:
	curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.9/2020-08-04/bin/linux/amd64/kubectl
	chmod +x ./kubectl
	sudo mv ./kubectl /usr/local/bin
	echo 'export PATH=$PATH:$HOME/bin' >> ~/.bash_profile
	kubectl version --short --client


#Not related to the Project
start-up:
	sudo apt-get update
	sudo apt-get install python3-venv
	pip install virtualenv

env-setup:
	python3 -m venv ~/.microservice-app

env:
	which python3
	python3 --version

env-install:
	sudo apt install -y pip
	pip install --upgrade pip &&\
	pip install --trusted-host pypi.python.org -r requirements.txt

env-run:
	source ~/.microservice-app/bin/activate

localenv: env-instal env-setup env