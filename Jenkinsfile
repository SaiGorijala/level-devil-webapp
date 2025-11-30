pipeline {
    agent any

    tools {
        maven 'maven3'
        jdk 'jdk17'
    }

    environment {
        DEPLOY_USER = "ubuntu"
        DEPLOY_HOST = "13.53.131.137"   // <-- replace with your u4 IP
        REMOTE_TOMCAT_PATH = "/opt/tomcat/webapps"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build WAR') {
            steps {
                sh "mvn clean package"
            }
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.war'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    withSonarQubeEnv('sonarqube') {
                        sh """
                            mvn sonar:sonar \
                            -Dsonar.login=${SONAR_TOKEN}
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('(Optional) Upload to Nexus') {
            steps {
                echo "Nexus upload can be enabled later if needed."
            }
        }

        stage('Deploy WAR to Tomcat') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'deploy-ssh', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                    sh """
                        WAR_FILE=`ls target/*.war`

                        echo "Uploading WAR to Tomcat..."
                        scp -i ${SSH_KEY} -o StrictHostKeyChecking=no $WAR_FILE ${DEPLOY_USER}@${DEPLOY_HOST}:${REMOTE_TOMCAT_PATH}/ROOT.war

                        echo "Restarting Tomcat..."
                        ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} 'sudo systemctl restart tomcat'

                        echo "Deployment completed."
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline + Deployment Successful!"
        }
        failure {
            echo "Pipeline Failed — Check Console Output."
        }
    }
}
