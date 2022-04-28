$PROJ_DIR = "E:\jenkins\workspace\EORS\R17.0.0-GitLab\1-Check-GitLab-Changes-EORS\EORS\.git"
$GIT_DIR = "E:\jenkins\workspace\EORS\R17.0.0-GitLab\1-Check-GitLab-Changes-EORS\EORS\.git"
$Git_BRANCH = $env:Git_BRANCH
$JIRA_PROJ = 'EORS'

write-host "Project name : $JIRA_PROJ"
write-host $env:cmadminJIRA
$secure = $env:cmadminJIRA | convertTo-SecureString -AsPlainText -Force
write-host $secure
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
$unsecure = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
write-host $BSTR
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "cmadmin", $unsecure)))
write-host $base64AuthInfo
$devComplete = $(Invoke-RestMethod -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) } -Uri https://jira.chartdev.net/rest/api/latest/search?jql=project=$JIRA_PROJ+AND+status=%22Dev+Completed%22).issues.key

write-host "##################### All the Current Dev Completed Issues from Jira #################"
write-host ""
echo $devComplete
write-host ""
write-host "######################################################################################"


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
                    $noOfChanges = $(git --git-dir=$GIT_DIR --work-tree=$PROJ_DIR diff $tagName --stat) | Measure-object -Line
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

write-host "################## Completed Issues Found: Creating Tag ############################"
write-host ''
write-host "Git Branch: $Git_BRANCH"
$Git_BRANCH = [string]$Git_BRANCH

if ($tags.get_length() -gt 0) {
    $last_tag = git --git-dir=$GIT_DIR describe --tags --abbrev=0
    write-host "-------- Printing the last tag from this branch --------"
    write-host "Last tag:: $last_tag"
}

if ($tags.get_length() -eq 0) {
    write-host ">>> No previous tags found. Creaing a new one from branch name <<<"
    $newTagRev = 1
    $last_tag_str = $Git_BRANCH + '.' + $newTagRev
}
else {
    write-host ">>> Previous tag found. Incrementing last tag <<<"
    $last_tag_splitted = $last_tag.Split('.')
    $last_tag_splitted[-1] = [int]$last_tag_splitted[-1] + 1
    $last_tag_str = $last_tag_splitted -Join "."
}

$tagComment = 'New Tag Created - ' + $last_tag_str + '. ' + 'Issues Included:  ' + $issueFound
$tagComment = "`'$tagComment`'"

write-host "Creating new Tag:  $last_tag_str"
write-host "Copy from: $Git_BRANCH"
write-host ''
write-host "######################################################################################"

git --git-dir=$GIT_DIR tag -a $last_tag_str -m "$tagComment"

git --git-dir=$GIT_DIR -c http.sslVerify=false push http://chartcm:Djy5Q+Sq4NA!SQcV@chartgitlab.chartdev.net/chartcm/chart-eors.git $last_tag_str

"GIT_TAG=$last_tag_str" | Out-File new.tag -Encoding ASCII
"TAG_VER=$last_tag_str" | Out-File tag.ver -Encoding ASCII


"EMAIL_BODY=$email_body" | Out-File email.body -Encoding ASCII