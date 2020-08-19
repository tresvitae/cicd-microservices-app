start-up:
	sudo apt-get update
	sudo apt-get install python3-venv
	pip install virtualenv

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
