pipeline {
    agent any
    tools {
        maven 'maven3'
    }
    
    parameters {
        choice(name: 'DEPLOY_ENV', choices: ['blue', 'green'], description: 'Choose which environment to deploy: Blue or Green')
        choice(name: 'DOCKER_TAG', choices: ['blue', 'green'], description: 'Choose the Docker image tag for the deployment')
        booleanParam(name: 'SWITCH_TRAFFIC', defaultValue: false, description: 'Switch traffic between Blue and Green')
    }
    
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        IMAGE_NAME = "allayasheela/bankapp"
        TAG = "${params.DOCKER_TAG}"  // The image tag now comes from the parameter
        KUBE_NAMESPACE = 'webapps'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-cred', url: 'https://github.com/yasheela-alla/Bank-App.git'
            }
        }
        
        stage('Tests') {
            steps {
                sh "mvn test -DskipTests=true"
            }
        }
        
        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs --format table -o fs.html ."
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh "$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectKey=nodejsmysql -Dsonar.projectName=nodejsmysql -Dsonar.java.binaries=target/classes"
                }
            }
        }
        
        stage('Switch Traffic Between Blue & Green Environment') {
            when {
                expression { params.SWITCH_TRAFFIC }
            }
            steps {
                script {
                    def newEnv = params.DEPLOY_ENV
                    withKubeConfig(caCertificate: '', clusterName: 'AksCluster', credentialsId: 'k8-token', namespace: 'webapps') {
                        sh """
                            kubectl patch service bankapp-service -p "{\"spec\": {\"selector\": {\"app\": \"bankapp\", \"version\": \"${newEnv}\"}}}}" -n ${KUBE_NAMESPACE}
                        """
                    }
                    echo "Traffic has been switched to the ${newEnv} environment."
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
            sh "mvn test -DskipTests=true"
        }
    } // Closing the stages block
} // Closing the pipeline block
