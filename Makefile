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

setup:
	python3 -m venv ~/.microservice-app

env:
	which python3
	python3 --version

install:
	sudo apt install -y pip
	pip install --upgrade pip &&\
	pip install --trusted-host pypi.python.org -r requirements.txt

run:
	source ~/.microservice-app/bin/activate

localenv: instal setup env

tidy:
	sudo apt install -y tidy