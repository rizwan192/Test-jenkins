param([string]$buildWorkspace,[string]$CHART_APP,[string]$TAG_VER)
write-host "buildWorkspace:  $buildWorkspace"
write-host "CHART_APP:  $CHART_APP"
write-host "TAG_VER:  $TAG_VER"
# Get the version number of the release
$CONFIG_PREFIX = 'chart-' + $CHART_APP
$CONFIG_FILE = $CONFIG_PREFIX + '.nuspec'
$PRODUCT_VERSION = $TAG_VER.Trim("R"," ")
write-host "PRODUCT_VER:  $PRODUCT_VERSION"
# copy output for package creation

# define source locations
$verFolder = Get-ChildItem "$buildWorkspace\install\output" | Where-Object {$_.PSIsContainer -and $_.Name.StartsWith("R")}
write-host "$verFolder"
$appSource = "$buildWorkspace\install\output\" + $verFolder + "\lab\APPTEMPLATE"
$expSource = "$buildWorkspace\install\output\" + $verFolder + "\lab\EXPTEMPLATE"
# files to exclude from installer
$exclude = @('install_services.cmd','install_webapps.cmd')
# Copy app code folders
Copy-Item $appSource -Destination "$buildWorkspace\CM_Package\tools\app_code\app" -Recurse -Exclude $exclude
# Copy exp code folders
Copy-Item $expSource -Destination "$buildWorkspace\CM_Package\tools\app_code\exp" -Recurse -Exclude $exclude
# Create new choco package

# Update nuspec file
$FilePath = "$buildWorkspace\CM_Package\$CONFIG_FILE"
Write-Host "Updating Config File:  $FilePath"
(Get-Content ($FilePath)) | Foreach-Object {$_ -replace "    <version>.+", ("    <version>" + $PRODUCT_VERSION + "</version>")} | Set-Content ($FilePath)
choco pack
# Build Package
cd $buildWorkspace\CM_Package
choco pack
# Add package back to repo
$PACKAGE_FILE = '.\' + $CONFIG_PREFIX + '.' + $PRODUCT_VERSION + '.nupkg'
Write-Host "Adding File To Repo:  $PACKAGE_FILE"
choco push $PACKAGE_FILE --source "'http://chartcmci01/chocolatey'" -k="'chocolateyrocks'" --force