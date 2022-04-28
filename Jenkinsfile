pipeline {
    agent any

    stages {
        stage('Checkout'){
            steps{
                echo 'Cleaning up generated files...'
                step([$class: 'WsCleanup'])
                echo 'Getting Latest Code...'
                checkout scm
            }
        }      
        stage('Copying Scripts from local dir to jenkins dir') {
            steps {
                echo 'Copying Scripts...'
                 powershell returnStatus: true, script: "ls"
                 powershell returnStatus: true, script: "mkdir CM_Scripts"
                 powershell returnStatus: true, script: "Copy-Item 'C:/ProgramData/Jenkins/.jenkins/workspace/test/test.js' -Destination 'C:/ProgramData/Jenkins/.jenkins/workspace/test/test'"
                 powershell returnStatus: true, script: "${env.WORKSPACE}"
                 powershell returnStatus: true, script: "cd CM_Scripts"
                 powershell returnStatus: true, script: "ls"
            }
            // steps {
            //     echo 'Copying Pacakges...'
            //      powershell returnStatus: true, script: "ls"
            //      powershell returnStatus: true, script: "mkdir CM_Package"
            //      powershell returnStatus: true, script: "Copy-Item 'C:/ProgramData/Jenkins/.jenkins/workspace/test/test.js' -Destination 'C:/ProgramData/Jenkins/.jenkins/workspace/test/test'"
            //      powershell returnStatus: true, script: "Get-Location"
            //      powershell returnStatus: true, script: "cd CM_Package"
            //      powershell returnStatus: true, script: "ls"
            // }
        }

			// stage('Check JIRA') {
			// steps {
			// 	echo 'Checking JIRA for ATMS tickets ready for deploy...'
			// 	withCredentials([usernamePassword(credentialsId: 'cmadminJIRA', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
			// 		powershell returnStatus: true, script: ".\\CM_Scripts\\checkJIRAIssues.ps1 -GIT_URL ${env.GIT_URL} -GIT_BRANCH ${env.GIT_BRANCH} -WORKING_DIR ${env.WORKSPACE} -cmadminUSER ${env.USER} -cmadminPASS ${env.PASS}"
			// 		}
				
			// 	// Use a script block to read variable set in the completed.array file
			// 	script {
			// 		def props = readProperties file: 'completed.array'
			// 		env.COMPLETED_ITEMS = props.COMPLETED_ITEMS
			// 		}

			// 	catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {

			// 		script {
			// 			if (env.COMPLETED_ITEMS) {
			// 				echo "Completed issues found"
			// 				bat "EXIT 0"
			// 				} else {
			// 					echo "No completed issues found"
			// 					bat "EXIT 1"
			// 					}
			// 			}
					
			// 		}
					
			// 	}
			// }


        stage('Next stage ... ') {
            steps {
                echo 'Next stage step ....'
            }
        }
    }
}