pipeline {
    agent any
    stages {
        stage('Checkout'){
            steps{
                step([$class: 'WsCleanup'])
                checkout scm
                checkout([$class: 'GitSCM'])
                powershell returnStatus: true, script: "ls"
            }
        }      
        // stage('Getting scripts from remote') {
        //     steps{
        //         powershell returnStatus: true, script: "mkdir scripts"
        //         powershell returnStatus: true, script: "cd scripts"
        //         checkout([$class: 'GitSCM', branches:[[name: '*/master']],
        //         doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], 
        //         userRemoteConfigs: [[url: "https://github.com/rizwan192/Leetcode-problem-picker.git"]]]) 
        //         powershell returnStatus: true, script: "ls"
        //     }
        // } 
   
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