pipeline {
    agent any
    stages {
        stage('Checkout'){
            steps{
                 checkout scm
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
                 powershell returnStatus: true, script: "ls"
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}