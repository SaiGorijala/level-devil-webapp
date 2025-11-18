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

<img width="1462" height="315" alt="Image" src="https://github.com/user-attachments/assets/e86fb8d5-c87a-4423-aa87-3707225ddcb2" />

## 3.2 Add User to Docker Group

```
usermod -aG docker ubuntu
```

## 3.3 Add purmissions

```
sudo chmod 600 /var/run/docker.sock
```

<img width="774" height="34" alt="Image" src="https://github.com/user-attachments/assets/db7b4c6e-5fbe-46d0-b60a-9031fb730d01" />

# 🧩 4. Clone the Java WebApp Repository

```
git clone <your-github-repo>
cd <repo>
```

<img width="938" height="164" alt="Image" src="https://github.com/user-attachments/assets/7d700d86-59f9-4aff-9113-1b977651d6d7" />

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

<img width="1676" height="330" alt="Image" src="https://github.com/user-attachments/assets/b46769b7-d0aa-4877-b516-5ae71ddc50ca" />

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

<img width="1321" height="780" alt="Image" src="https://github.com/user-attachments/assets/364d3800-dc52-4de1-b251-a42fba988a49" />

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


<img width="1766" height="471" alt="Image" src="https://github.com/user-attachments/assets/6e732c7e-07b7-4c04-a49e-6f82fc502051" />

## 7.3 Added Tools in Jenkins

Maven

SonarQube Scanner

JDK

Git

<img width="1600" height="618" alt="Image" src="https://github.com/user-attachments/assets/f5a46591-90df-4c09-a0c1-acce65b6efca" />
<img width="1582" height="561" alt="Image" src="https://github.com/user-attachments/assets/57173b2b-2ef9-4ca6-8d30-77775b9c55e0" />
<img width="1596" height="578" alt="Image" src="https://github.com/user-attachments/assets/a51f82c7-4da4-4bb8-a6dd-d5e6dde8a323" />

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

```
pipeline {
    agent any

    environment {
        NEXUS_URL      = "http://3.17.13.134:8081/repository/maven-snapshots/"
        GROUP_ID_PATH  = "com/example"
        APP_NAME       = "level-devil-webapp"
        DOCKER_REPO    = "sgorijala513/tomcat"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
                script {
                    echo "Commit: ${env.GIT_COMMIT}"
                }
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

                        // WAR file name
                        def WAR = sh(
                            script: "ls target/*.war | head -n 1",
                            returnStdout: true
                        ).trim()

                        // Extract version from POM
                        def VERSION = sh(
                            script: "grep -m1 \"<version>\" pom.xml | sed 's|.*<version>||; s|</version>.*||'",
                            returnStdout: true
                        ).trim()

                        // Upload path
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

                        // Extract VERSION again
                        def VERSION = sh(
                            script: "grep -m1 \"<version>\" pom.xml | sed 's|.*<version>||; s|</version>.*||'",
                            returnStdout: true
                        ).trim()

                        echo "Building docker image with VERSION=${VERSION}"

                        sh """
                            docker build \
                                --build-arg NEXUS_URL=${NEXUS_URL} \
                                --build-arg GROUP_ID_PATH=${GROUP_ID_PATH} \
                                --build-arg APP_NAME=${APP_NAME} \
                                --build-arg VERSION=${VERSION} \
                                --build-arg NEXUS_USER=${NEXUS_USER} \
                                --build-arg NEXUS_PASS=${NEXUS_PASS} \
                                -t ${DOCKER_REPO}:${GIT_COMMIT.take(7)} \
                                -t ${DOCKER_REPO}:latest \
                                .
                        """
                    }
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

                // The SSH key ID must match Jenkins credentials EXACTLY
                sshagent(['docker-server']) {

                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@3.17.13.134 'docker pull ${DOCKER_REPO}:latest'
                        ssh -o StrictHostKeyChecking=no ubuntu@3.17.13.134 'docker stop tomcat 2>/dev/null || true'
                        ssh -o StrictHostKeyChecking=no ubuntu@3.17.13.134 'docker rm tomcat 2>/dev/null || true'
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
```


# 🐳 9. Dockerfile Summary

This project uses a multi-stage Dockerfile:

Stage 1 — Downloader

Accepts build arguments (Nexus URL, version, credentials)

Downloads the WAR from Nexus

Stage 2 — Tomcat Deployment

Uses your custom Tomcat base image

Copies downloaded WAR to ROOT.war

```
# -------- Stage 1: Downloader --------
FROM eclipse-temurin:17-jre AS downloader

ARG NEXUS_URL
ARG GROUP_ID_PATH
ARG APP_NAME
ARG VERSION
ARG NEXUS_USER
ARG NEXUS_PASS

# Construct URL correctly using ARG (NOT ENV)
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Build the Nexus path only during RUN (correct ARG expansion)
RUN ARTIFACT_URL="${NEXUS_URL}${GROUP_ID_PATH}/${APP_NAME}/${VERSION}/${APP_NAME}-${VERSION}.war" && \
    echo "Downloading WAR from: ${ARTIFACT_URL}" && \
    curl -u "${NEXUS_USER}:${NEXUS_PASS}" -L "${ARTIFACT_URL}" -o /tmp/app.war

# -------- Stage 2: Tomcat --------
FROM tomcat:10.1-jdk17-temurin

# Remove the default ROOT app
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy the downloaded war as ROOT.war for auto-deploy
COPY --from=downloader /tmp/app.war /usr/local/tomcat/webapps/ROOT.war
```


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
```
http://<ec2-public-ip>:8080
```
You should see the deployed Java application.

<img width="1800" height="1169" alt="Image" src="https://github.com/user-attachments/assets/f02ef18e-8d6c-4296-95fd-53179a7f24c1" />


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

<img width="1800" height="1169" alt="Image" src="https://github.com/user-attachments/assets/1551c47d-b06f-4918-892d-0d3dcc604da0" />

#🎉 Project Completed Successfully
