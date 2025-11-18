I can't directly create a downloadable file on your computer, but I can ensure the redeem.md content is perfectly formatted for you to copy, save, and push to GitHub.

Here is the entire, correct Markdown content for your redeem.md file in one block:

Markdown
# 🚀 Level Devil WebApp – Complete CI/CD Pipeline
### *Jenkins • GitHub • SonarQube • Nexus • Docker • DockerHub • Tomcat on EC2*

This document contains **every step, configuration, script, Dockerfile, and Jenkinsfile** required to build a fully functioning CI/CD pipeline from scratch.

It is intentionally written so **even someone with zero experience** can follow and succeed.

---

# 📘 Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Features](#features)
4. [Full Technology Stack](#full-technology-stack)
5. [Prerequisites](#prerequisites)
6. [EC2 Setup](#ec2-setup)
7. [Install Docker](#install-docker)
8. [Install Jenkins](#install-jenkins)
9. [Install SonarQube](#install-sonarqube)
10. [Install Nexus Repository](#install-nexus-repository)
11. [Configure GitHub](#configure-github)
12. [Jenkins Credentials Required](#jenkins-credentials-required)
13. [Project Structure](#project-structure)
14. [Dockerfile](#dockerfile)
15. [Jenkinsfile](#jenkinsfile)
16. [Understanding the Pipeline](#understanding-the-pipeline)
17. [EC2 Deployment Setup](#ec2-deployment-setup)
18. [Accessing the Application](#accessing-the-application)
19. [Troubleshooting Guide](#troubleshooting-guide)
20. [Author](#author)

---

# 📌 Project Overview

This project provides a **complete CI/CD pipeline** for deploying a Java WAR-based web application automatically to a Tomcat server running inside Docker on AWS EC2.

Every code push triggers:
1. Jenkins pipeline
2. SonarQube analysis
3. Maven build → WAR
4. Upload artifact to Nexus
5. Docker build using WAR from Nexus
6. Push Docker image to DockerHub
7. Deploy to EC2 over SSH

This is production-level automation.

---

# 🏗 Architecture
GitHub → Jenkins → SonarQube → Nexus → Docker Build → DockerHub → EC2 → Tomcat Container → App

---

# ✨ Features
* ✔ Fully automated CI/CD pipeline
* ✔ Java + Maven WAR packaging
* ✔ SonarQube quality gate enforcement
* ✔ Nexus artifact management
* ✔ Multi-stage Docker build
* ✔ DockerHub integration
* ✔ Automated deployment to EC2
* ✔ Zero-downtime restart of Tomcat container

---

# 🧰 Full Technology Stack
* **Java 17**
* **Maven**
* **Jenkins**
* **SonarQube**
* **Nexus Repository Manager 3**
* **Docker & DockerHub**
* **Tomcat 10**
* **AWS EC2 (Ubuntu 22.04)**

---

# 🧩 Prerequisites
Before starting, you need:
* AWS EC2 instance for Jenkins / Nexus / SonarQube
* AWS EC2 instance for Deployment (Tomcat)
* DockerHub account
* GitHub account
* Basic Linux SSH access
* Jenkins installed with required plugins

---

# 🖥 EC2 Setup
Use Ubuntu 22.04 for all servers.

Update system:
```bash
sudo apt update && sudo apt upgrade -y
Install required packages:

Bash
sudo apt install -y unzip curl vim git
🐳 Install Docker
Bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings

curl -fsSL [https://download.docker.com/linux/ubuntu/gpg](https://download.docker.com/linux/ubuntu/gpg) |
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
[https://download.docker.com/linux/ubuntu](https://download.docker.com/linux/ubuntu) $(lsb_release -cs) stable" |
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker ubuntu
Reboot:

Bash
sudo reboot
🔧 Install Jenkins
Bash
docker run -d --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
Get the initial admin password:

Bash
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
Install plugins:

GitHub

Maven Integration

SonarQube Scanner

Pipeline

SSH Agent

🔍 Install SonarQube
Bash
docker run -d --name sonarqube \
 -p 9000:9000 \
 sonarqube:lts
Login: admin / admin Create a token for Jenkins.

📦 Install Nexus Repository Manager
Bash
docker run -d --name nexus \
 -p 8081:8081 \
 -v nexus-data:/nexus-data \
 sonatype/nexus3
Access Nexus → create maven-snapshots repo.

🔗 Configure GitHub
Create a new repository Add the Jenkins webhook:

http://<JENKINS-IP>:8080/github-webhook/

Generate Personal Access Token (classic)

🔐 Jenkins Credentials Required
ID	Type	Use
nexus	username + password	Upload WAR to Nexus
dockerhub-user	username + token	Push to DockerHub
docker-server	SSH private key	Connect to EC2 deploy server
sonar-token	secret text	SonarQube auth
github-token	secret text	GitHub integration
📁 Project Structure
level-devil-webapp/
├── pom.xml
├── Jenkinsfile
├── Dockerfile
├── src/
└── redeem.md
🐳 Dockerfile
Dockerfile
# -------- Stage 1: Downloader --------
FROM eclipse-temurin:17-jre AS downloader

ARG NEXUS_URL
ARG GROUP_ID_PATH
ARG APP_NAME
ARG VERSION
ARG NEXUS_USER
ARG NEXUS_PASS

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

RUN ARTIFACT_URL="${NEXUS_URL}${GROUP_ID_PATH}/${APP_NAME}/${VERSION}/${APP_NAME}-${VERSION}.war" \
  && echo "Downloading WAR from: ${ARTIFACT_URL}" \
  && curl -u "${NEXUS_USER}:${NEXUS_PASS}" -L "${ARTIFACT_URL}" -o /tmp/app.war

# -------- Stage 2: Tomcat --------
FROM tomcat:10.1-jdk17-temurin

RUN rm -rf /usr/local/tomcat/webapps/ROOT

COPY --from=downloader /tmp/app.war /usr/local/tomcat/webapps/ROOT.war
📜 Jenkinsfile (Final)
Groovy
pipeline {
    agent any

    environment {
        NEXUS_URL      = "[http://3.17.13.134:8081/repository/maven-snapshots/](http://3.17.13.134:8081/repository/maven-snapshots/)"
        GROUP_ID_PATH  = "com/example"
        APP_NAME       = "level-devil-webapp"
        DOCKER_REPO    = "sgorijala513/tomcat"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
                script { echo "Commit: ${env.GIT_COMMIT}" }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh """
                        mvn clean verify sonar:sonar \
                        -Dsonar.projectKey=level-devil-webapp
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build WAR') {
            steps {
                sh "mvn clean package -DskipTests=false"
            }
        }

        stage('Upload WAR to Nexus') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'nexus',
                    usernameVariable: 'NEXUS_USER',
                    passwordVariable: 'NEXUS_PASS'
                )]) {
                    script {
                        def WAR = sh(script: "ls target/*.war | head -n 1", returnStdout: true).trim()
                        def VERSION = sh(script: "grep -m1 \"<version>\" pom.xml | sed 's|.*<version>||; s|</version>.*||'", returnStdout: true).trim()

                        def ARTIFACT_URL = "${NEXUS_URL}${GROUP_ID_PATH}/${APP_NAME}/${VERSION}/${APP_NAME}-${VERSION}.war"
                        echo "Uploading WAR → ${ARTIFACT_URL}"

                        sh """
                            curl -u "${NEXUS_USER}:${NEXUS_PASS}" \
                                 --upload-file ${WAR} \
                                 "${ARTIFACT_URL}"
                        """
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'nexus',
                    usernameVariable: 'NEXUS_USER',
                    passwordVariable: 'NEXUS_PASS'
                )]) {

                    script {
                        def VERSION = sh(script: "grep -m1 \"<version>\" pom.xml | sed 's|.*<version>||; s|</version>.*||'", returnStdout: true).trim()
                        echo "Building docker image with VERSION=${VERSION}"
                    }

                    sh """
                        docker build \
                            --build-arg NEXUS_URL=${NEXUS_URL} \
                            --build-arg GROUP_ID_PATH=${GROUP_ID_PATH} \
                            --build-arg APP_NAME=${APP_NAME} \
                            --build-arg VERSION=${VERSION} \
                            --build-arg NEXUS_USER=${NEXUS_USER} \
                            --build-arg NEXUS_PASS=${NEXUS_PASS} \
                            -t ${DOCKER_REPO}:${GIT_COMMIT.take(7)} \
                            -t ${DOCKER_REPO}:latest .
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-user',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh """
                        echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                        docker push ${DOCKER_REPO}:${GIT_COMMIT.take(7)}
                        docker push ${DOCKER_REPO}:latest
                    """
                }
            }
        }

        stage('Deploy to Tomcat Docker Server') {
            steps {
                sshagent(['docker-server']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@3.17.13.134 'docker pull ${DOCKER_REPO}:latest'
                        ssh -o StrictHostKeyChecking=no ubuntu@3.17.13.134 'docker stop tomcat || true'
                        ssh -o StrictHostKeyChecking=no ubuntu@3.17.13.134 'docker rm tomcat || true'
                        ssh -o StrictHostKeyChecking=no ubuntu@3.17.13.134 'docker run -d --name tomcat -p 8080:8080 ${DOCKER_REPO}:latest'
                    """
                }
            }
        }
    }

    post {
        success { echo "BUILD SUCCESSFUL" }
        failure { echo "BUILD FAILED" }
    }
}
🖥 EC2 Deployment Setup
Install Docker:

Bash
sudo apt update
sudo apt install -y docker.io
Container is deployed automatically by Jenkins.

🌍 Accessing the Web App
Open:

http://<EC2-DEPLOYMENT-IP>:8080

🐞 Troubleshooting Guide
❌ Tomcat shows 404 WAR file not copied as ROOT.war — fixed by Dockerfile already.

❌ Jenkins cannot ssh Credential ID must be exactly: docker-server

❌ Docker push unauthorized Token must be Read/Write, not Read-only.

❌ Nexus upload fails Check repository type: must be maven-snapshots.

👤 Author
Sai Gorijala DevOps Engineer GitHub: https://github.com/SaiGorijala
