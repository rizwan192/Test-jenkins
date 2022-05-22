param([string]$TAG_VER,[string]$TARGET_SERVER,[string]$USERNAME,[string]$PASSWORD)
$ErrorActionPreference = 'Stop'
$SecurePassword = $PASSWORD | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $USERNAME, $SecurePassword

# get the install version of the app
$PRODUCT_VERSION = $TAG_VER.Trim("R"," ")
$PRODUCT_VERSION = "`'$PRODUCT_VERSION`'"

$APPSERVER = $TARGET_SERVER + "atmsapp"
$APPPARAMS = "`'/ENV:$TARGET_SERVER /CFG:app /STARTSERVICES`'"

$stopTomcat = "`$tomcatProc = Get-Process tomcat9 -ErrorAction SilentlyContinue; if (!`$tomcatProc.HasExited) { write-host `"tomcat is running - stopping process`"; `$tomcatProc | Stop-Process -Force }"
$appInstCmd = "choco upgrade chart-atms -y --params $APPPARAMS --version $PRODUCT_VERSION --force --source http://chartcmci01/chocolatey/"

write-host "Running commands on $APPSERVER"
write-host "Tomcat Stop Command:  $stopTomcat"
write-host "Install Command:  $appInstCmd"

$tomcatScript = [scriptblock]::Create($stopTomcat)
$result = $(Invoke-command -computer $APPSERVER -Credential $cred -ScriptBlock $tomcatScript)
write-host $result

$appInstScript = [scriptblock]::Create($appInstCmd)
$result = $(Invoke-command -computer $APPSERVER -Credential $cred -ScriptBlock $appInstScript)
write-host $result
$EXPSERVER = $TARGET_SERVER + "atmsexp"
$EXPPARAMS = "`'/ENV:$TARGET_SERVER /CFG:exp /STARTSERVICES`'"

$stopTomcat = "`$tomcatProc = Get-Process tomcat9 -ErrorAction SilentlyContinue; if (!`$tomcatProc.HasExited) { write-host `"tomcat is running - stopping process`"; `$tomcatProc | Stop-Process -Force }"
$expInstCmd = "choco upgrade chart-atms -y --params $EXPPARAMS --version $PRODUCT_VERSION --force --source http://chartcmci01/chocolatey/"

write-host "Running commands on $EXPSERVER"
write-host "Tomcat Stop Command:  $stopTomcat"
write-host "Install Command:  $expInstCmd"

$tomcatScript = [scriptblock]::Create($stopTomcat)
$result = $(Invoke-command -computer $EXPSERVER -Credential $cred -ScriptBlock $tomcatScript)
write-host $result

$expInstScript = [scriptblock]::Create($expInstCmd)
$result = $(Invoke-command -computer $EXPSERVER -Credential $cred -ScriptBlock $expInstScript)
write-host $result
