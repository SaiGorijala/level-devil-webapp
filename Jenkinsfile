pipeline {
    agent any

    environment {
        APP_NAME       = "level-devil-webapp"
        GROUP_ID_PATH  = "com/example"
        DOCKER_REPO    = "sgorijala513/tomcat"
        NEXUS_URL      = "http://3.17.13.134:8081/repository/maven-snapshots/"
        SONAR_PROJECT  = "level-devil-webapp"

        // Remote Tomcat Docker host
        REMOTE_HOST    = "ubuntu@YOUR_TOMCAT_SERVER_IP"
        REMOTE_KEY     = "ssh-key"
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
                        -Dsonar.projectKey=${SONAR_PROJECT}
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
                        WAR = sh(script: "ls target/*.war | head -n 1", returnStdout: true).trim()

                        VERSION = sh(
                            script: """mvn -q -Dexec.executable=echo \
                                -Dexec.args='${project.version}' \
                                org.codehaus.mojo:exec-maven-plugin:1.6.0:exec""",
                            returnStdout: true
                        ).trim()

                        ARTIFACT_URL = "${NEXUS_URL}${GROUP_ID_PATH}/${APP_NAME}/${VERSION}/${APP_NAME}-${VERSION}.war"

                        echo "Uploading → ${ARTIFACT_URL}"

                        sh """
                            curl -u "$NEXUS_USER:$NEXUS_PASS" \
                                 --upload-file ${WAR} \
                                 ${ARTIFACT_URL}
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
                        env.IMAGE_TAG = env.GIT_COMMIT.take(7)

                        sh """
                            docker build \
                              --build-arg NEXUS_URL=${NEXUS_URL} \
                              --build-arg GROUP_ID_PATH=${GROUP_ID_PATH} \
                              --build-arg APP_NAME=${APP_NAME} \
                              --build-arg VERSION=${VERSION} \
                              --build-arg NEXUS_USER=${NEXUS_USER} \
                              --build-arg NEXUS_PASS=${NEXUS_PASS} \
                              -t ${DOCKER_REPO}:${IMAGE_TAG} \
                              -t ${DOCKER_REPO}:latest .
                        """
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_REPO}:${IMAGE_TAG}
                        docker push ${DOCKER_REPO}:latest
                    """
                }
            }
        }

        stage('Deploy to Tomcat Docker Server') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: REMOTE_KEY,
                    keyFileVariable: 'SSH_KEY'
                )]) {

                    sh """
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${REMOTE_HOST} "
                            docker pull ${DOCKER_REPO}:${IMAGE_TAG}
                            docker stop tomcat-app || true
                            docker rm tomcat-app || true
                            docker run -d --name tomcat-app -p 8080:8080 ${DOCKER_REPO}:${IMAGE_TAG}
                        "
                    """
                }
            }
        }
    }

    post {
        success {
            echo "SUCCESS: Deployed ${DOCKER_REPO}:${IMAGE_TAG} to Remote Tomcat Server"
        }
        failure {
            echo "BUILD FAILED."
        }
    }
}
