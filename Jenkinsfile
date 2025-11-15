pipeline {
    agent any

    environment {
        APP_NAME        = "level-devil-webapp"
        GROUP_ID_PATH   = "com/example"
        DOCKER_REPO     = "sgorijala513/tomcat"
        NEXUS_URL       = "http://3.17.13.134:8081/repository/maven-snapshots/"
        SONAR_PROJECT   = "level-devil-webapp"
        DEPLOY_SERVER   = "ubuntu@3.145.21.140"   // <<< CHANGE THIS IP (your Tomcat Docker server)
        DEPLOY_PATH     = "/home/ubuntu"
        CONTAINER_NAME  = "tomcat-level-devil"
    }

    stages {

        /* ---------------------- CHECKOUT ---------------------- */
        stage('Checkout Code') {
            steps {
                checkout scm
                script {
                    echo "Commit: ${env.GIT_COMMIT}"
                }
            }
        }

        /* ---------------------- SONAR ---------------------- */
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

        /* ---------------------- BUILD WAR ---------------------- */
        stage('Build WAR') {
            steps {
                sh "mvn clean package -DskipTests=false"
            }
        }

        /* ---------------------- UPLOAD WAR TO NEXUS ---------------------- */
        stage('Upload WAR to Nexus') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'nexus',
                    usernameVariable: 'NEXUS_USER',
                    passwordVariable: 'NEXUS_PASS'
                )]) {

                    script {
                        sh '''
                            WAR=$(ls target/*.war | head -n 1)

                            VERSION=$(mvn -q \
                                -Dexec.executable=echo \
                                -Dexec.args='${project.version}' \
                                org.codehaus.mojo:exec-maven-plugin:1.6.0:exec)

                            ARTIFACT_PATH="${GROUP_ID_PATH}/${APP_NAME}/${VERSION}"
                            ARTIFACT_URL="${NEXUS_URL}${ARTIFACT_PATH}/${APP_NAME}-${VERSION}.war"

                            echo "Uploading → $ARTIFACT_URL"

                            curl -u "$NEXUS_USER:$NEXUS_PASS" \
                                 --upload-file "$WAR" \
                                 "$ARTIFACT_URL"
                        '''
                    }
                }
            }
        }

        /* ---------------------- BUILD DOCKER IMAGE ---------------------- */
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
                              --build-arg NEXUS_USER=${NEXUS_USER} \
                              --build-arg NEXUS_PASS=${NEXUS_PASS} \
                              -t ${DOCKER_REPO}:${IMAGE_TAG} \
                              -t ${DOCKER_REPO}:latest \
                              .
                        """
                    }
                }
            }
        }

        /* ---------------------- PUSH DOCKER IMAGE ---------------------- */
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

        /* ---------------------- DEPLOY TO TOMCAT DOCKER SERVER ---------------------- */
        stage('Deploy to Tomcat Docker Server') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'deploy-key',
                    keyFileVariable: 'SSH_KEY'
                )]) {

                    sh """
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${DEPLOY_SERVER} '
                            docker pull ${DOCKER_REPO}:latest &&
                            docker stop ${CONTAINER_NAME} || true &&
                            docker rm ${CONTAINER_NAME} || true &&
                            docker run -d --name ${CONTAINER_NAME} -p 8080:8080 ${DOCKER_REPO}:latest
                        '
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Deployment successful → http://<SERVER-IP>:8080/"
        }
        failure {
            echo "BUILD FAILED."
        }
    }
}
