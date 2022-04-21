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
                 sh "ls -lat"
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}