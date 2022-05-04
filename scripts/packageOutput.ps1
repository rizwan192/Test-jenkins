param([string]$buildWorkspace,[string]$CHART_APP,[string]$TAG_VER)
write-host "buildWorkspace:  $buildWorkspace"
write-host "CHART_APP:  $CHART_APP"
write-host "TAG_VER:  $TAG_VER"
$CONFIG_PREFIX = 'chart-' + $CHART_APP
$CONFIG_FILE = $CONFIG_PREFIX + '.nuspec'
$PRODUCT_VERSION = $TAG_VER.Trim("R"," ")
write-host "PRODUCT_VER:  $PRODUCT_VERSION"
ls $buildWorkspace
ls "$buildWorkspace\install\output"
$verFolder = Get-ChildItem "$buildWorkspace\install\output" | Where-Object {$_.PSIsContainer -and $_.Name.StartsWith("R")}
write-host "$verFolder"
$appSource = "$buildWorkspace\install\output\" + $verFolder + "\lab\APPTEMPLATE"
$expSource = "$buildWorkspace\install\output\" + $verFolder + "\lab\EXPTEMPLATE"
$exclude = @('install_services.cmd','install_webapps.cmd')
ls $appSource
ls $expSource
Copy-Item $appSource -Destination "$buildWorkspace\CM_Package\tools\app_code\app" -Recurse -Exclude $exclude
Copy-Item $expSource -Destination "$buildWorkspace\CM_Package\tools\app_code\exp" -Recurse -Exclude $exclude
$FilePath = "$buildWorkspace\CM_Package\$CONFIG_FILE"
Write-Host "Updating Config File:  $FilePath"
ls $buildWorkspace\CM_Package
(Get-Content ($FilePath)) | Foreach-Object {$_ -replace "    <version>.+", ("    <version>" + $PRODUCT_VERSION + "</version>")} | Set-Content ($FilePath)
ls $buildWorkspace\CM_Package
choco pack
cd $buildWorkspace\CM_Package
choco pack
$PACKAGE_FILE = '.\' + $CONFIG_PREFIX + '.' + $PRODUCT_VERSION + '.nupkg'
Write-Host "Adding File To Repo:  $PACKAGE_FILE"
choco push $PACKAGE_FILE --source "'http://chartcmci01/chocolatey'" -k="'chocolateyrocks'" --force