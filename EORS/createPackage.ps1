write-host "Move checkout code from the sub-directory to the Workspace root level"
If((test-path E:\jenkins\workspace\EORS-GitLab\R16.3.0-New\3-Create-Package-EORS\tools))
{
      Remove-Item 'E:\jenkins\workspace\EORS-GitLab\R16.3.0-New\3-Create-Package-EORS\tools' -Force  -Recurse -ErrorAction SilentlyContinue
}
Copy-Item "E:\jenkins\workspace\EORS-GitLab\R16.3.0-New\3-Create-Package-EORS\chocolatey\chart-eors\*" -Destination "E:\jenkins\workspace\EORS-GitLab\R16.3.0-New\3-Create-Package-EORS\tools" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "E:\jenkins\workspace\EORS-GitLab\R16.3.0-New\3-Create-Package-EORS\tools\chart-eors.nuspec" -Destination "E:\jenkins\workspace\EORS-GitLab\R16.3.0-New\3-Create-Package-EORS" -Recurse -Force -ErrorAction SilentlyContinue

# Remove the checked out directory
Remove-Item 'E:\jenkins\workspace\EORS-GitLab\R16.3.0-New\3-Create-Package-EORS\chocolatey' -Force  -Recurse -ErrorAction SilentlyContinue
New-Item -ItemType "directory" -Path "E:\jenkins\workspace\EORS-GitLab\R16.3.0-New\3-Create-Package-EORS\tools\app_code\EorsReportingService"
Copy-Item -Path "$env:SOURCE_WORKSPACE\Package-Output\*" -Destination "E:\jenkins\workspace\EORS-GitLab\R16.3.0-New\3-Create-Package-EORS\tools\app_code" -Recurse -Force -ErrorAction SilentlyContinue

# Get the version number of the release
$CONFIG_FILE = $env:CHART_APP + '.nuspec'
$GIT_TAG = $env:GIT_TAG
$PRODUCT_VERSION = $GIT_TAG
$PRODUCT_VERSION = $PRODUCT_VERSION.Trim("R"," ")
# Update nuspec file
$FilePath = ".\$CONFIG_FILE"
(Get-Content ($FilePath)) | Foreach-Object {$_ -replace "    <version>.+", ("    <version>" + $PRODUCT_VERSION + "</version>")} | Set-Content ($FilePath)

# Copy built code into package folder (this step copies everything from the Package-Output folder)
Remove-Item 'E:\jenkins\workspace\EORS-GitLab\R16.3.0-New\3-Create-Package-EORS\tools\*.nuspec' -Force  -Recurse -ErrorAction SilentlyContinue

# Build Package
choco pack

# Add package to repo
$PACKAGE_FILE = '.\' + $env:CHART_APP + '.' + $PRODUCT_VERSION + '.nupkg'
Write-Host "Adding File To Repo:  $PACKAGE_FILE"

choco push $PACKAGE_FILE --source "'http://chartcmci03/chocolatey'" -k="'chocolateyrocks'" --force
