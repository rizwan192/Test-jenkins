pipeline {
    agent any
    stages {
        stage('Checkout'){
            steps{
                echo 'Cleaning up generated files...'
                echo 'Getting Latest Code...'
                checkout scm
            }
        }      
        stage('Copying Scripts') {
            steps {
                echo 'Copying Scripts...'
                 powershell returnStatus: true, script: "ls"
                 powershell returnStatus: true, script: "mkdir CM_Scripts"
                 powershell returnStatus: true, script: "mkdir CM_Package"
                 powershell returnStatus: true, script: "Copy-Item -Force -Recurse -Verbose 'E:/jenkins/chart-cm/ATMS_Scripts/*' -Destination '${env.WORKSPACE}/CM_Scripts'"
                 powershell returnStatus: true, script: "Copy-Item -Force -Recurse -Verbose 'E:/jenkins/chart-cm/chart-atms/*' -Destination '${env.WORKSPACE}/CM_Package'"
                 powershell returnStatus: true, script: "ls"
            }
        }

			stage('Check JIRA') {
			steps {
				echo 'Checking JIRA for ATMS tickets ready for deploy...'
				withCredentials([usernamePassword(credentialsId: 'cmadminJIRA', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
					powershell returnStatus: true, script: ".\\CM_Scripts\\checkJIRAIssues.ps1 -GIT_BRANCH ${env.GIT_BRAN} -GIT_DIR ${env.WORKSPACE} -cmadminUSER ${env.USER} -cmadminPASS ${env.PASS}"
					}
				
				// Use a script block to read variable set in the completed.array file
				script {
					def props = readProperties file: 'completed.array'
					env.COMPLETED_ITEMS = props.COMPLETED_ITEMS
					}

				catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {

					script {
						if (env.COMPLETED_ITEMS) {
							echo "Completed issues found"
							bat "EXIT 0"
							} else {
								echo "No completed issues found"
								bat "EXIT 1"
								}
						}
					
					}
					
				}
			}
           stage('Create Tag') {
			when {
                expression {
                    env.COMPLETED_ITEMS
					}
				}
			
			steps {
				powershell returnStatus: true, script: ".\\CM_Scripts\\createTag.ps1 -COMPLETED_ITEMS '${env.COMPLETED_ITEMS}' -GIT_BRANCH ${env.GIT_BRAN} -GIT_DIR ${env.WORKSPACE}"
				
				script {
					def props = readProperties file: 'new.tag'
					env.TAG_NAME = props.TAG_NAME
					}
				
				script {
					def props = readProperties file: 'tag.ver'
					env.TAG_VER = props.TAG_VER
					}
				}
			}

			stage('Code Build') {
		
			when {
                expression {
                    env.COMPLETED_ITEMS
					}
				}
			
			tools {
					gradle 'Gradle-7.3.3'
					jdk 'JDK15.0.2'
				}
				
			steps {
				echo 'Building Code With Gradle...'
				bat "gradle build -PatmsVersion=${TAG_VER}"
				}
				
			}

		   stage('Install Package Build') {

			when {
                expression {
                    env.COMPLETED_ITEMS
					env.TAG_VER
					}
				}
			
			tools {
				gradle 'Gradle-7.3.3'
				jdk 'JDK15.0.2'
				}
				
			steps {
				// powershell returnStatus: true, script: "Remove-Item '${env.WORKSPACE}/install/output' -Force -Recurse"
				echo 'Building Install Packages With Gradle...'
				bat "gradle :gradleproj:install:templates -PatmsVersion=${TAG_VER}"
				}
			}


			stage('Build Package') {
			
			when {
                expression {
                    env.COMPLETED_ITEMS
					}
				}
			
			steps {
				echo 'Building ATMS Package File into the Chocolatey Repo...'
				powershell returnStatus: true, script: ".\\CM_Scripts\\packageOutput.ps1 -buildWorkspace ${env.WORKSPACE} -CHART_APP atms -TAG_VER '${env.TAG_VER}'"				}
				
			}

			
			
        stage('Next stage ... ') {
            steps {
                echo 'Next stage step ....'
            }
        }
    }
}