pipeline {
    agent any

    environment {
        DOCKERHUB_USER = credentials('dockerhub-user')
        DOCKERHUB_PASS = credentials('dockerhub-pass')
        NEXUS_USER = credentials('nexus-creds-user')
        NEXUS_PASS = credentials('nexus-creds-pass')
        NEXUS_URL = "http://3.17.13.134:8081/repository/maven-releases"
        DOCKER_IMAGE = "saigorijala/level-devil-webapp"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
                script {
                    COMMIT_ID = sh(script: "git rev-parse HEAD", returnStdout: true).trim()
                    echo "Commit: ${COMMIT_ID}"
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
                withCredentials([usernamePassword(credentialsId: 'nexus-creds',
                        usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    script {
                        // SAFE VERSION EXTRACTION
                        VERSION = sh(
                            script: "grep -m1 '<version>' pom.xml | cut -d '>' -f2 | cut -d '<' -f1",
                            returnStdout: true
                        ).trim()

                        echo "Extracted version: ${VERSION}"

                        sh """
                            curl -v -u $NEXUS_USER:$NEXUS_PASS \
                            --upload-file target/level-devil-webapp.war \
                            ${NEXUS_URL}/com/example/level-devil-webapp/${VERSION}/level-devil-webapp-${VERSION}.war
                        """
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${DOCKER_IMAGE}:${VERSION} .
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                sh """
                    echo ${DOCKERHUB_PASS} | docker login -u ${DOCKERHUB_USER} --password-stdin
                    docker push ${DOCKER_IMAGE}:${VERSION}
                """
            }
        }

        stage('Deploy to Tomcat Docker Server') {
            steps {
                sh """
                    docker rm -f level-devil || true
                    docker pull ${DOCKER_IMAGE}:${VERSION}
                    docker run -d --name level-devil -p 8080:8080 ${DOCKER_IMAGE}:${VERSION}
                """
            }
        }
    }

    post {
        success {
            echo "BUILD SUCCESSFUL!"
        }
        failure {
            echo "BUILD FAILED"
        }
    }
}
