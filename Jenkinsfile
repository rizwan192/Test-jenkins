pipeline {
    agent any
    stages {
        stage('Checkout'){
            steps{
                powershell returnStatus: true, script: "ls -Recurse * | rm"
				powershell returnStatus: true, script: "Remove-Item ./email.body -Force"
				powershell returnStatus: true, script: "Remove-Item ./new.tag -Force"
				powershell returnStatus: true, script: "Remove-Item ./tag.ver -Force"
                checkout scm
                checkout([$class: 'GitSCM',
                workspaceUpdater: [$class: 'CheckoutUpdater']])
            }
        }
        stage('Copying files') {
            steps {
                echo 'Copying...'

                 powershell returnStatus: true, script: "ls"
                 powershell returnStatus: true, script: "mkdir test"
                 powershell returnStatus: true, script: "Copy-Item 'C:/ProgramData/Jenkins/.jenkins/workspace/test/test.js' -Destination 'C:/ProgramData/Jenkins/.jenkins/workspace/test/test'"
                 powershell returnStatus: true, script: "Get-Location"
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