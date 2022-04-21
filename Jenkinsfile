pipeline {
    agent any
    stages {
        stage('checkout'){
            steps{
        checkout([
            $class: 'GitSCM',
            branches: scm.branches,
            extensions: scm.extensions + [[$class: 'LocalBranch'], [$class: 'WipeWorkspace']],
            doGenerateSubmoduleConfigurations: false
        ])
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }




    }
}


                // locations: [[cancelProcessOnExternalsFail: true, credentialsId: '65335887-e117-49bf-abd6-64c6436c4c8d', depthOption: 'infinity', ignoreExternalsOption: true, local: './CM_Scripts', remote: 'https://github.com/rizwan192/Test-jenkins/blob/test/test.js']],
