# Ensure the build fails if there is a problem.
# The build will fail if there are any errors on the remote machine too
$ErrorActionPreference = 'Stop'

# Create a PSCredential Object using the "User" and "Password" parameters that you passed to the job
$SecurePassword = $env:PASSWORD | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $env:USERNAME, $SecurePassword

# get the environment name
$APP_NAME = $env:CHART_APP.Split('-') | Select-Object -Last 1

# set package parameters
$ENV_NAME = $env:SERVERNAME -split $APP_NAME | Select-Object -First 1
$PARAMS = "`'/ENV:$ENV_NAME`'"

# get the install version of the app
$GIT_TAG = $env:GIT_TAG
$PRODUCT_VERSION = $GIT_TAG.Split('/') | Select-Object -Last 1
$PRODUCT_VERSION = $PRODUCT_VERSION.Trim("R"," ")
$PRODUCT_VERSION = "`'$PRODUCT_VERSION`'"

# Invoke a command on the remote machine.
$instCmd = "choco upgrade $env:CHART_APP -y --params $PARAMS --version $PRODUCT_VERSION --force --source http://chartcmci01/chocolatey/"

write-host "Running commands on $env:SERVERNAME"
write-host "Install Command:  $instCmd"

$instScript = [scriptblock]::Create($instCmd)

$result = $(Invoke-command -computer $env:SERVERNAME -Credential $cred -ScriptBlock $instScript)

write-host $result