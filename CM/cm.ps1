# Get the version number of the release
$CONFIG_PREFIX = 'chart-' + $env:CHART_APP
$CONFIG_FILE = $CONFIG_PREFIX + '.nuspec'
$PRODUCT_VERSION = $env:GIT_TAG
$PRODUCT_VERSION = $PRODUCT_VERSION.Trim("R"," ")
# Update nuspec file
$FilePath = ".\$CONFIG_FILE"
Write-Host "Updating Config File:  $FilePath"
(Get-Content ($FilePath)) | Foreach-Object {$_ -replace "    <version>.+", ("    <version>" + $PRODUCT_VERSION + "</version>")} | Set-Content ($FilePath)

# Copy built code into package folder (this step copies everything from the Package-Output folder)
Write-Host "Copying Packages From:  $env:SOURCE_WORKSPACE\Package-Output\"
Write-Host "$env:WORKSPACE"
Copy-Item -Path "$env:SOURCE_WORKSPACE\Package-Output\*" -Destination "$env:WORKSPACE\tools\app_code\"-Recurse -Force -ErrorAction SilentlyContinue

# Build Package
choco pack

# Update Package:

# Remove previous iteration in repo - NOT REQUIRED IF USING PUSH COMMANDS
#$PREV_DIR = 'F:\Chocolatey-Server\Packages\' + $CONFIG_PREFIX + '\' + $PRODUCT_VERSION
#Write-Host "Removing Previous Version:  $PREV_DIR"
#Remove-Item $PREV_DIR -Force -Recurse

#$PREV_FILE = 'F:\Chocolatey-Server\Packages\' + $CONFIG_PREFIX + '.' + $PRODUCT_VERSION + '.nupkg'
#Write-Host "Removing Previous Version:  $PREV_FILE"
#Remove-Item $PREV_FILE -Force

# Add package back to repo
$PACKAGE_FILE = '.\' + $CONFIG_PREFIX + '.' + $PRODUCT_VERSION + '.nupkg'
Write-Host "Adding File To Repo:  $PACKAGE_FILE"
#Copy-Item $PACKAGE_FILE -Destination "F:\Chocolatey-Server\Packages\"

choco push $PACKAGE_FILE --source "'http://chartcmci01/chocolatey'" -k="'chocolateyrocks'" --force