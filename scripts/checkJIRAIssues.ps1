param([string]$GIT_BRANCH,[string]$GIT_DIR,[string]$cmadminUSER,[string]$cmadminPASS)
$GIT_DIR = $GIT_DIR+"\.git"
Write-Host "$GIT_BRANCH"
Write-Host "$GIT_DIR"
# Ensure the build fails if there is a problem.
$ErrorActionPreference = 'Stop'

###################################################################################
#### NOTE: This MUST match the FULL NAME (NOT abbreviation) of the JIRA project that corresponds to the app you are checking
$JIRA_PROJ = 'ATMS'
###################################################################################

# Create a password variable using the stored password from the Jenkins Global Passwords
$secure = $cmadminPASS | ConvertTo-SecureString -AsPlainText -Force

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
$unsecure = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $cmadminUSER,$unsecure)))

########################################################################################
########################################################################################
################################# PROD JIRA URL ########################################
$devComplete = $(Invoke-RestMethod -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Uri https://jira.chartdev.net/rest/api/latest/search?jql=project=$JIRA_PROJ+AND+status=%22Dev+Completed%22).issues.key
write-host "##################### All the Current Dev Completed Issues from Jira #################"
write-host ""
echo $devComplete
write-host ""
write-host "######################################################################################"
########################################################################################
########################################################################################


$arr = git --git-dir=$GIT_DIR tag | findstr $Git_BRANCH
$tags = $arr -Split "<<>>"
write-host "#################### Tags and commits for branch:: $Git_BRANCH #######################"
write-host ""
$commits = @()
if ($tags.get_length() -eq 0) {
    write-host "----- No tags found under the branch :: $Git_BRANCH. Fetching all commits from the branch -----"
    $all_commits_under_this_branch = git --git-dir=$GIT_DIR log --oneline
    foreach ($commit in $all_commits_under_this_branch) {
        $commits += $commit.substring(8) + "###"
    }
    if ($commits.get_length() -gt 0) {
        $commit_splitted = $commits.Split('###')
    }
}
else {
    write-host "--- All the previous tags from the branch :: $Git_BRANCH --------------"
    echo $tags
    foreach ($tag in $tags) {
        $all_commits_under_this_tag = git --git-dir=$GIT_DIR log $tag --oneline
        foreach ($commit in $all_commits_under_this_tag) {
            $commits += $commit.substring(8) + "###"
        }
    }
    if ($commits.get_length() -gt 0) {
        $commit_splitted = $commits.Split('###')
    }
}

if ($commit_splitted.get_length() -eq 0) {
    $commit_splitted += "No commits under the branch"
}
write-host ""
write-host "#######################################################################################"

$tagDetailsList = @()
$i = 0
if ($tags.get_length() -gt 0) {
    foreach ($t in $tags) {
        $tag_splitted = $t.Split('.')
        $tagRev = [int]$tag_splitted[-1]
        $commit_for_this_tag = @()
        $all_commits_under_this_tag = git --git-dir=$GIT_DIR log $t --oneline
        foreach ($commit in $all_commits_under_this_tag) {
            $commit_for_this_tag += $commit.substring(8) + "###"
            $commit_for_this_tag_splitted = $commit_for_this_tag.Split('###')
        }
        
        $tagDetails = @{
            tagName = $t
            tagRev  = $tagRev
            comMsg  = $commit_for_this_tag_splitted
        }
        $tagDetailsList += $tagDetails
        $i += 1
    }

    write-host "############################### All the Tags detail #######################################"
    write-host ""
    echo $tagDetailsList
    write-host ""
    write-host "####################################################################################"
}


$issueFound = @()
write-host "############################# Looking for Jira issues #################################"
write-host ""
if ($tags.get_length() -gt 0) {
    write-host "--------- Looking for Jira issues in all the commits from the tags ------------"
    foreach ($d in $devComplete) {
        foreach ($td in $tagDetailsList) {
            $tagName = $td.tagName
            $comMsg = $td.comMsg
            $tagRev = $td.tagRev
            if ($comMsg -like "*$d*" ) {
                echo ">>> Found issue $d that included in tag $tagName <<<"
                echo ">>> Issue $d was last tagged at revision $tagRev <<<"
                $exist = git --git-dir=$GIT_DIR tag | findstr $tagName
                if ($exist -ne '0') {
                    $noOfChanges = $(git --git-dir=$GIT_DIR --work-tree=$GIT_DIR diff $tagName --stat) | Measure-object -Line
                    if ($noOfChanges -eq '0') {
                        ">>> No new changes. Issue $d Not Updated <<<"
                    }
                    else {
                        ">>> Changes found. Issue $d has been updated since last tagged. Adding to completed List.<<<"
                        $issueFound += $d
                    }
                }
                break
            }
        }
    }
}
else {
    write-host "--- Since no tags found, looking for Jira issues in all the commits from the Branch ---"
    
    foreach ($d in $devComplete) {
        foreach ($com in $commit_splitted) {
            if ($com -like "*$d*" ) {
                Write-host ">>> Found issue $d that included in commit: $com <<<"
                Write-host ">>> Issue $d has been updated since last tagged. Adding to completed List <<<"
                $issueFound += $d;
            }   
        }
    }
    if ($issueFound.get_length() -eq 0) {
        $issueFound += "No Issue";
    }
}


write-host ''
write-host "#####################################################################################"

write-host "###################### Issues completed since the latest tag ########################"
write-host ''


$all_commits_under_this_branch = git --git-dir=$GIT_DIR log --oneline
foreach ($commit in $all_commits_under_this_branch) {
    $commits += $commit.substring(8) + "###"
}
if ($commits.get_length() -gt 0) {
    $commit_splitted = $commits.Split('###')
}
foreach ($d in $devComplete) {
    foreach ($com in $commit_splitted) {
        if ($com -like "*$d*" ) {
            Write-host ">>> Found issue $d that included in commit: $com <<<"
            Write-host ">>> Issue $d has been updated since last tagged. Adding to completed List <<<"
            $issueFound += $d;
        }   
    }
}
if ($issueFound.get_length() -eq 0) {
    $issueFound += "No Issue";
}

$issueFound = $issueFound | sort -unique
echo $issueFound
write-host ''
write-host "#####################################################################################"

"COMPLETED_ITEMS=$issueFound" | Out-File completed.array -Encoding ASCII