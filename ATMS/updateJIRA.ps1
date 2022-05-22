param([string]$TARGET_SERVER,[string]$cmadminUSER,[string]$cmadminPASS,[string]$TAG_NAME,[string]$COMPLETED_ITEMS)

# Ensure the build fails if there is a problem.
$ErrorActionPreference = 'Stop'


###################################################################################
###################################################################################

###### NEEDED TO CONNECT TO JIRA TEST SERVER ONLY #####

#add-type @"
#    using System.Net;
#    using System.Security.Cryptography.X509Certificates;
#    public class TrustAllCertsPolicy : ICertificatePolicy {
#        public bool CheckValidationResult(
#            ServicePoint srvPoint, X509Certificate certificate,
#            WebRequest request, int certificateProblem) {
#            return true;
#        }
#    }
#"@
#[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

###################################################################################
###################################################################################


# Create a password variable using the stored password from the Jenkins Global Passwords
$secure = $cmadminPASS | ConvertTo-SecureString -AsPlainText -Force

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
$unsecure = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $cmadminUSER,$unsecure)))

$currentDate = (Get-Date)

# get the install version of the app
$TAG_NAME = $TAG_NAME.Split('/') | Select-Object -Last 1

$releaseVer = $TAG_NAME -replace '.*\/'
$issueComment = ('This issue has been deployed to ' + $TARGET_SERVER + ' with ATMS version ' + $releaseVer + ' on ' + $currentDate)
$issueComment = "`"$issueComment`""
write-host "Issue Comment:  $issueComment"

$completedList = $COMPLETED_ITEMS.split(" ")

#############################################################################################################
$emailComment = "Team,<br/><br/>The ATMS installation on $TARGET_SERVER has been upgraded to <b>ATMS $releaseVer</b>.<br/><br/>The release contents of <b>ATMS $releaseVer</b> include:<br/><br/>"

foreach ($i in $completedList) {

  $issueSummary = $(Invoke-RestMethod -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Uri https://jira.chartdev.net/rest/api/latest/search?jql=key=$i).issues.fields.summary
  write-host "Summary:  $issueSummary"
  $emailComment = $emailComment + "<b><font color=`"blue`">$i`:`</font></b> $issueSummary<br/>"

}

write-host "Email Comment:  $emailComment"
#############################################################################################################

$deployJson = "{`"transition`":{`"id`": `"191`"},`"update`":{`"comment`":[{`"add`":{`"body`": $issueComment}}]},`"fields`":{`"assignee`":{`"name`":`"`"}}}"

foreach ($a in $completedList) {

   write-host "TRANSITIONING ISSUE:  $a"

   ########################################################################################
   ########################################################################################
   ################################# TEST JIRA URL ########################################

   #$issueUri = "https://10.222.118.81/rest/api/2/issue/$a/transitions?expand=transitions.fields"

   ################################# PROD JIRA URL ########################################

   $issueUri = "https://jira.chartdev.net/rest/api/2/issue/$a/transitions?expand=transitions.fields"
   write-host $issueUri

   ########################################################################################
   ########################################################################################

   try
   {
   $deployResponse = (Invoke-RestMethod -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -uri $issueUri -Method POST -Body $deployJson -ContentType "application/json").id
   write-host "DEPLOY RESPONSE:   $deployResponse"
   }
   catch
   {
       $ErrorMessage = $_
       Write-Error ($ErrorMessage)
   }
}

# Write email comment to a file
"EMAIL_BODY=$emailComment" | Out-File email.body -Encoding ASCII

# Write tag name to a file