# Complete CI/CD Pipeline Documentation  
## Java WebApp • Jenkins • Docker • SonarQube • Nexus • Custom Tomcat • GitHub

---

# 📘 1. Project Overview

This project implements a complete CI/CD pipeline using:

- **AWS EC2 t3.large (16GB storage)**
- **Docker** to run all services
- **Jenkins** for CI/CD automation
- **SonarQube** for code quality analysis
- **Nexus Repository** for artifact storage
- **Custom Tomcat Server** as a deployment target
- **DockerHub** for hosting production images
- **GitHub** as SCM + Jenkinsfile + Dockerfile

This documentation is written so even someone **with zero experience** can follow and complete the project.

---

# 🚀 2. EC2 Setup

## 2.1 Launch the EC2 Instance
- Instance Type: **t3.large**
- Storage: **16GB**
- OS: Ubuntu 22.04 recommended
- Open ports:
  - 22 (SSH)
  - 8080 (Tomcat)
  - 8081 (Nexus)
  - 8083 (Jenkins)
  - 9000 (SonarQube)

## 2.2 Update the System

```
sudo su
apt update && apt upgrade -y
```

# 🐳 3. Install Docker

## 3.1 Install Docker Engine

```
apt install docker.io -y
systemctl enable docker
systemctl start docker
```

## 3.2 Add User to Docker Group

```
usermod -aG docker ubuntu
```

# 🧩 4. Clone the Java WebApp Repository

```
git clone <your-github-repo>
cd <repo>
```

This repo contains:
Java WebApp
Jenkinsfile
Dockerfile


# 📦 5. Deploy DevOps Tools in Docker Containers

All services run on one EC2 instance via Docker.

## 5.1 Jenkins

```
docker run -d \
  --name jenkins \
  -p 8083:8080 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

## 5.2 SonarQube

```
docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  sonarqube:lts
```

## 5.3 Nexus Repository Manager

```
docker run -d \
  --name nexus \
  -p 8081:8081 \
  sonatype/nexus3
```


# 🐱‍🏍 6. Custom Tomcat Server Setup

The default Tomcat container did not serve applications correctly because Tomcat stored files in:
```
/usr/local/tomcat/webapps.dist
```
But Tomcat actually serves applications from:

```
/usr/local/tomcat/webapps
```

## ✔ 6.1 Fixed by Moving Files

```
cp -r /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps/
```

## ✔ 6.2 Modified Configuration Files

```
settings.xml
```

Configured Maven + Nexus repository access.

```
context.xml
```

Enabled manager access for remote deployments.

## ✔ 6.3 Created a Custom Tomcat Image

After fixing configuration:

```
docker commit <tomcat-container-id> custom-tomcat:v1
docker tag custom-tomcat:v1 <dockerhub-username>/custom-tomcat:v1
docker push <dockerhub-username>/custom-tomcat:v1
```
This custom Tomcat image is now the base image used for deployments.

# 🛠 7. Jenkins Setup

## 7.1 Installed Required Plugins

GitHub
Docker Pipeline
Pipeline
Maven Integration
SonarQube Scanner
SSH Agent
Nexus Artifact Uploader


## 7.2 Configured Credentials
Credential ID	Type	Purpose
docker-server-key	SSH Private Key	EC2 deployment
dockerhub-user	User/Password	Push to DockerHub
nexus	User/Password	Upload to Nexus
github-token	PAT	GitHub webhooks


## 7.3 Added Tools in Jenkins
Maven
SonarQube Scanner
JDK
Git


# 📑 8. Jenkinsfile Pipeline Summary
The pipeline performs:
Checkout from GitHub
SonarQube Analysis
Quality Gate Check
Build WAR using Maven
Upload WAR to Nexus
Build Docker Image using Custom Tomcat
Push Docker Image to DockerHub
Deploy to EC2 Tomcat via SSH
The pipeline file is stored in GitHub so all changes automatically trigger Jenkins.


# 🐳 9. Dockerfile Summary
This project uses a multi-stage Dockerfile:
Stage 1 — Downloader
Accepts build arguments (Nexus URL, version, credentials)
Downloads the WAR from Nexus
Stage 2 — Tomcat Deployment
Uses your custom Tomcat base image
Copies downloaded WAR to ROOT.war


# 🔁 10. Complete CI/CD Workflow

Here is the full automation pipeline:
Developer pushes code → GitHub
GitHub webhook → Jenkins starts build
Jenkins clones repository
Jenkins runs SonarQube analysis
Jenkins builds WAR file
WAR uploaded to Nexus Repository
Jenkins builds Docker image
Image pushed to DockerHub
Jenkins SSHs into EC2
Jenkins pulls new Docker image
Old Tomcat container is removed
New container starts with updated ROOT.war
Tomcat serves the latest version of the application


#🌐 11. Access the Application
Open in browser:
http://<ec2-public-ip>:8080
You should see the deployed Java application.


# 🐞 12. Troubleshooting Guide
Tomcat Shows 404
Ensure ROOT.war exists
Ensure custom Tomcat was used
Ensure container restarted during deployment
Jenkins SSH Credential Errors
Credential ID must match Jenkinsfile exactly
Use correct private key (not .pub)
Nexus Upload Fails
Repository Type: Maven (snapshots)
Correct username/password in credentials
Docker Push Fails
Ensure correct DockerHub repo name
Credentials must match Jenkinsfile


# 🏁 13. Final Result
You now have a complete CI/CD setup with:
✔ GitHub
✔ Jenkins
✔ SonarQube
✔ Nexus
✔ Docker
✔ Custom Tomcat
✔ Automated deployment
This pipeline continuously builds, analyzes, stores, packages, and deploys your Java application end-to-end.


#🎉 Project Completed Successfully
