pipeline {
    agent any

    parameters {
        choice(name: 'DEPLOY_ENV', choices: ['blue', 'green'], description: 'Select the environment to deploy')
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        TRIVY_IMAGE = 'aquasec/trivy:latest'
        DOCKER_CREDENTIALS_ID = 'allayasheela' // Your Docker credentials
        DEPLOYMENT_NAME = 'bankapp' // Name of your deployment
        IMAGE_NAME = "bankapp:${params.DEPLOY_ENV}-image" // Define the image based on the chosen environment
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm // Check out the source code from the repository
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    // Assuming you're using Maven or a similar build tool
                    sh 'mvn clean test'
                }
            }
        }

        stage('Trivy FS Scan') {
            steps {
                script {
                    // Perform a Trivy scan on the filesystem
                    sh "docker run --rm ${TRIVY_IMAGE} --quiet filesystem ."
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh "$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectKey=nodejsmysql -Dsonar.projectName=nodejsmysql"
                }
            }
        }
        
        stage('Switch Traffic Between Blue & Green Environment') {
            when {
                expression { return params.SWITCH_TRAFFIC }
            }
            steps {
                script {
                    def newEnv = params.DEPLOY_ENV

                    // Always switch traffic based on DEPLOY_ENV
                    withKubeConfig(caCertificate: '', clusterName: 'AksCluster', contextName: '', credentialsId: 'k8-token', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'akscluster-dns-5zu2vc1m.hcp.australiaeast.azmk8s.io') {
                        sh '''
                            kubectl patch service bankapp-service -p "{\\"spec\\": {\\"selector\\": {\\"app\\": \\"bankapp\\", \\"version\\": \\"''' + newEnv + '''\\"}}}" -n ${KUBE_NAMESPACE}
                        '''
                    }
                    echo "Traffic has been switched to the ${newEnv} environment."
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    // Check if the application is running in the selected environment
                    sh "kubectl rollout status deployment/${DEPLOYMENT_NAME}"
                }
            }
        }
    }

    post {
        always {
            // Clean up any resources or send notifications
            cleanWs()
        }
    }
}
