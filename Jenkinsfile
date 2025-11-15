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
                        def WAR = sh(
                            script: "ls target/*.war | head -n 1",
                            returnStdout: true
                        ).trim()

                        // 🔥 FIXED VERSION EXTRACTION (no escaping needed)
                        def VERSION = sh(
                            script: "grep -m1 '<version>' pom.xml | sed 's/.*<version>//; s/<\\\\/version>.*//' ",
                            returnStdout: true
                        ).trim()

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
                    sh """
                        docker build \
                            --build-arg NEXUS_URL=${NEXUS_URL} \
                            --build-arg GROUP_ID_PATH=${GROUP_ID_PATH} \
                            --build-arg APP_NAME=${APP_NAME} \
                            --build-arg NEXUS_USER=${NEXUS_USER} \
                            --build-arg NEXUS_PASS=${NEXUS_PASS} \
                            -t ${DOCKER_REPO}:${GIT_COMMIT.take(7)} \
                            -t ${DOCKER_REPO}:latest \
                            .
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
