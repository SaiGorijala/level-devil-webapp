pipeline {
  agent any

  environment {
    // change these to your values
    DOCKERHUB_REPO = "your_dockerhub_username/my-java-app"
    IMAGE_TAG = "${env.BUILD_NUMBER}"
    CONTAINER_NAME = "my-java-app"
    DEPLOY_HOST = "13.53.131.137"          // replace with your u4 IP
    DEPLOY_USER = "ubuntu"
    APP_PORT = "8080"                     // port inside container (tomcat default)
    HOST_PORT = "80"                      // port on u4 to expose app
  }

  tools {
    maven 'maven3'    // must match Jenkins Global Tool name
    jdk 'jdk17'       // must match Jenkins Global Tool name
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Unit Tests') {
      steps {
        sh 'mvn -B -DskipTests=false clean package'
      }
      post {
        always {
          archiveArtifacts artifacts: 'target/*.jar, target/*.war', fingerprint: true
          junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml'
        }
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
          // Ensure SonarQube configured in Jenkins with the name 'sonarqube'
          withSonarQubeEnv('sonarqube') {
            sh "mvn -B sonar:sonar -Dsonar.login=${SONAR_TOKEN}"
          }
        }
      }
    }

    stage('Wait for Quality Gate') {
      steps {
        // requires "Pipeline: SonarQube" and "Generic Webhook" support in Jenkins
        timeout(time: 2, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('(Optional) Upload artifact to Nexus') {
      when {
        expression { fileExists('pom.xml') } // only if Maven project
      }
      steps {
        withCredentials([usernamePassword(credentialsId: 'nexus-creds', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
          // This example uses curl to upload to Nexus raw or server that accepts raw uploads.
          // If you want to use Maven deploy to Nexus, configure distributionManagement in pom.xml and Jenkins Maven settings.
          sh '''
            ART=target/*.war
            if ls $ART 1> /dev/null 2>&1; then
              # example: upload to Nexus raw repository (adjust URL to your Nexus repo/path)
              curl -v -u $NEXUS_USER:$NEXUS_PASS --upload-file $ART "http://<u3-ip>:8081/repository/raw-hosted/$(basename $ART)"
            else
              echo "No WAR found to upload to Nexus"
            fi
          '''
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          sh "docker build -t ${env.DOCKERHUB_REPO}:${env.IMAGE_TAG} ."
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
            docker logout
          '''
        }
      }
    }

    stage('Deploy to u4') {
      steps {
        // Use SSH private key credential (type: SSH Username with private key) with ID 'deploy-ssh'
        withCredentials([sshUserPrivateKey(credentialsId: 'deploy-ssh', keyFileVariable: 'SSH_KEY', usernameVariable: 'DEPLOY_USER')]) {
          sh '''
            # copy SSH key to temporary location and set permissions
            chmod 600 ${SSH_KEY}
            # pull new image on remote, stop & replace container
            ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${DEPLOY_USER}@${DEPLOY_HOST} <<'SSH_EOF'
              docker login -u ${DOCKER_USER} -p ${DOCKER_PASS} >/dev/null 2>&1 || true
              docker pull ${DOCKERHUB_REPO}:${IMAGE_TAG}
              docker stop ${CONTAINER_NAME} || true
              docker rm ${CONTAINER_NAME} || true
              docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${APP_PORT} ${DOCKERHUB_REPO}:${IMAGE_TAG}
            SSH_EOF
          '''
        }
      }
    }
  }

  post {
    success {
      echo "Pipeline completed successfully: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
    }
    failure {
      echo "Pipeline failed — check console output."
    }
  }
}
