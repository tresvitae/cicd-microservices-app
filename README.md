
# Udacity Capstone Project 

Develop a CI/CD pipeline for micro services applications with rolling deployment strategy. 

Project created on EC2 Instance with ami-0a634ae95e11c6f91 (us-west-2 region) - Linux Ubuntu 18.04 LTS.

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
Pipeline: AWS Steps
Aqua MicroScanner.
8. Configure AquaMicroScanner in Jenkins
Add Docker installations in Global Tool Configuration in Jenkins
	Set Name (can be version of installed Docker in EC2, and Installation root: /usr/bin)
9. Setup GitHub project with Blue Ocean
10. Give Docker and Jenkins symbiotic permissions via command: sudo usermod -aG docker jenkins
