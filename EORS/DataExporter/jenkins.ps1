Write-Host "Current Workspace: $env:WORKSPACE"

# Server Credentials
$SecurePassword = $env:PASSWORD | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $env:USERNAME, $SecurePassword

# Stop EORSDataExporterService
Write-Host "Stopping Service"
$stopDataExporter = "`$dataExporterSer = Get-Service EORSDataExporterService -ErrorAction SilentlyContinue; if (!`$dataExporterSer.HasExited) { write-host `"EORSDataExporterService is running - stopping Service`"; `$dataExporterSer | Stop-Service -Force }"
$EORSDataExporterScriptStop = [scriptblock]::Create($stopDataExporter)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ScriptBlock $EORSDataExporterScriptStop

# Run RemoveEORSDataExporterService.bat file
Write-Host "Running remove bat Service"
$runRemove = "cd; cd D:\CHART\EorsDataExporter\InstallScripts;ls; cmd /c RemoveEorsDataExpoterService.bat"
$runRemoveScript = [scriptblock]::Create($runRemove)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ErrorAction Stop -ScriptBlock $runRemoveScript

#remove old data from D:chart
Write-Host "Removing old data from D:\chart"
$removeFolders = " cd; Remove-Item D:\CHART\EorsDataExporter\EorsDataExporterService -Recurse -Force"
$runRemoveFolders = [scriptblock]::Create($removeFolders)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ErrorAction Stop -ScriptBlock $runRemoveFolders

#Copy new dataexporter.zip to destination server
Write-Host "Copy new dataexporter.zip to destination server"
$session = New-PSSession -ComputerName $env:SERVERNAME -Credential $cred
Copy-Item "$env:WORKSPACE\Package-Output\dataexporter.zip" -Destination "D:\CHART\" -ToSession $session -Recurse -Force

# Unzip dataExport.zip, then remove installScripts and .zip file 
Write-Host "Unzip dataExport.zip"
$unzip = "Expand-Archive D:\CHART\dataexporter.zip -DestinationPath D:\CHART\ -Force; Remove-Item D:\CHART\dataexporter.zip -Recurse -Force; Remove-Item D:\CHART\InstallScripts -Recurse -Force ;Copy-Item 'D:\CHART\EORSDataExporterService' -Destination 'D:\CHART\EorsDataExporterService\' -Recurse -Force'; Rename-Item D:\CHART\EorsDataExporter\EORSDataExporterService D:\CHART\EorsDataExporter\EorsDataExporterService "
$unzipScript = [scriptblock]::Create($unzip)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ErrorAction Stop -ScriptBlock $unzipScript

# Run RegisterEorsDataExpoterService file
Write-Host "Run RegisterEorsDataExpoterService file"
$SERVER = [string]$env:SERVERNAME
$APP_NAME =  $SERVER.Substring(0,$SERVER.Length-1)
$APP_NAME = $APP_NAME+$env:CHART_APP+"app"
$runRegister = "cd; cd D:\CHART\EorsDataExporter\InstallScripts;ls; cmd /c RegisterEorsDataExpoterService.bat `$APP_NAME"
$runRegisterScript = [scriptblock]::Create($runRegister)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ErrorAction Stop -ScriptBlock $runRegisterScript

# Start EORSDataExporterService
Write-Host "Start EORSDataExporterService"
$startDataExporter = "`$dataExporterSer = Get-Service EORSDataExporterService -ErrorAction SilentlyContinue; `$dataExporterSer | Start-Service "
$EORSDataExporterScriptStart = [scriptblock]::Create($startDataExporter)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ScriptBlock $EORSDataExporterScriptStart
