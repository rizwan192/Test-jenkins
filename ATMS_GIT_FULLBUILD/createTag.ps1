param([string]$COMPLETED_ITEMS,[string]$GIT_BRANCH,[string]$GIT_DIR)

#################################################################################################################################################
#################################################################################################################################################
# Read in the completed issues found in JIRA

#$COMPLETED_ITEMS = Get-Content -Path completed.array

#################################################################################################################################################
#################################################################################################################################################


$GIT_DIR = $GIT_DIR+"\.git"
Write-Host "$GIT_BRANCH"
Write-Host "$GIT_DIR"
if ($COMPLETED_ITEMS) {
    write-host "################## Completed Issues Found: Creating Tag ############################"
    write-host ''
    write-host "Git Branch: $Git_BRANCH"

    $arr = git --git-dir=$GIT_DIR tag | findstr $Git_BRANCH
    $tags = $arr -Split "<<>>"
    write-host "#################### Tags for branch:: $Git_BRANCH #######################"
    write-host ""

 $issueFound = $COMPLETED_ITEMS
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
    

} Else {

          Write-Host "No Issues Completed - Exiting without creating tag"
		  Exit 1
     }