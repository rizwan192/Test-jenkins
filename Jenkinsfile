pipeline {
    agent any
    stages {
        stage('Checkout'){
            steps{
                 checkout scm
            }
        }
        stage('Copying files') {
            steps {
                echo 'Testing..'
                 powershell returnStatus: true, script: "ls"
                 powershell returnStatus: true, script: "mkdir test"
                 powershell returnStatus: true, script: "Copy-Item "C:\ProgramData\Jenkins\.jenkins\workspace\test\test.js" -Destination " C:\ProgramData\Jenkins\.jenkins\workspace\test\test""
                 powershell returnStatus: true, script: "cd test"
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