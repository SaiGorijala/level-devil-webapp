pipeline {
    agent any

    environment {
        APP_NAME       = "level-devil-webapp"
        GROUP_ID_PATH  = "com/example"
        DOCKER_REPO    = "sgorijala513/tomcat"
        NEXUS_URL      = "http://3.17.13.134:8081/repository/maven-snapshots/"
        SONAR_PROJECT  = "level-devil-webapp"
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
                withCredentials([
                    usernamePassword(
                        credentialsId: 'nexus',
                        usernameVariable: 'NEXUS_USER',
                        passwordVariable: 'NEXUS_PASS'
                    )
                ]) {

                    sh '''
                        WAR=$(ls target/*.war | head -n 1)

                        VERSION=$(mvn -q \
                            -Dexec.executable=echo \
                            -Dexec.args='${project.version}' \
                            org.codehaus.mojo:exec-maven-plugin:1.6.0:exec)

                        echo "WAR file: $WAR"
                        echo "VERSION: $VERSION"

                        UPLOAD_URL="${NEXUS_URL}${GROUP_ID_PATH}/${APP_NAME}/${VERSION}/${APP_NAME}-${VERSION}.war"

                        echo "Uploading to: $UPLOAD_URL"

                        curl -v -u "$NEXUS_USER:$NEXUS_PASS" \
                            --upload-file "$WAR" \
                            "$UPLOAD_URL"
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    env.IMAGE_TAG = env.GIT_COMMIT.take(7)

                    sh """
                        docker build \
                          -t ${DOCKER_REPO}:${IMAGE_TAG} \
                          -t ${DOCKER_REPO}:latest \
                          .
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {

                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_REPO}:${IMAGE_TAG}
                        docker push ${DOCKER_REPO}:latest
                    """
                }
            }
        }
    }

    post {
        success {
            echo "SUCCESS: Docker image pushed → ${DOCKER_REPO}:${IMAGE_TAG}"
        }
        failure {
            echo "BUILD FAILED."
        }
    }
}
