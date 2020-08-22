start-up:
	sudo apt-get update
	sudo apt-get install python3-venv
	pip install virtualenv

jenkins-install:
	sudo apt install -y openjdk-8-jdk
	wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
	sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
	sudo apt-get update
	sudo apt-get install -y jenkins

jenkins-start:
	sudo systemctl start jenkins
	sudo systemctl enable jenkins
	sudo systemctl status jenkins

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

tidy:
	sudo apt install -y tidy

docker:
	sudo apt-get update
	sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo apt-get install docker-ce docker-ce-cli containerd.io
	sudo chmod 666 /var/run/docker.sock
