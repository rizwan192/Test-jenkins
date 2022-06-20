Write-Host "Current Workspace: $env:WORKSPACE"

# Server Credentials
$SecurePassword = $env:PASSWORD | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $env:USERNAME, $SecurePassword

# Stop EORSDataExporterService
Write-Host "1. Stopping Service"
$stopDataExporter = "`$dataExporterSer = Get-Service EORSDataExporterService -ErrorAction SilentlyContinue; if (!`$dataExporterSer.HasExited) { write-host `"EORSDataExporterService is running - stopping Service`"; `$dataExporterSer | Stop-Service -Force }"
$EORSDataExporterScriptStop = [scriptblock]::Create($stopDataExporter)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ScriptBlock $EORSDataExporterScriptStop

# Run RemoveEORSDataExporterService.bat file
Write-Host "2. Running remove bat Service"
$runRemove = "cd; cd D:\CHART\EorsDataExporter\InstallScripts;ls; cmd /c RemoveEorsDataExpoterService.bat"
$runRemoveScript = [scriptblock]::Create($runRemove)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ErrorAction Stop -ScriptBlock $runRemoveScript

# Copy log folder from D:\CHART\EorsDataExporter\EorsDataExporterService\Logs
Write-Host "3. Copy log folder from D:Chart"
$runCopyLog = "cd; Copy-Item -Force -Recurse 'D:\CHART\EorsDataExporter\EorsDataExporterService\Logs\*'; -Destination 'D:\CHART\Logs'"
$runCopyLogScript = [scriptblock]::Create($runCopyLog)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ErrorAction Stop -ScriptBlock $runCopyLogScript

#remove old data from D:chart
Write-Host "4. Removing old data from D:\chart"
$removeFolders = " cd; Remove-Item D:\CHART\EorsDataExporter\EorsDataExporterService -Recurse -Force"
$runRemoveFolders = [scriptblock]::Create($removeFolders)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ErrorAction Stop -ScriptBlock $runRemoveFolders

#Copy new dataexporter.zip to destination server
Write-Host "5. Copy new dataexporter.zip to destination server"
$session = New-PSSession -ComputerName $env:SERVERNAME -Credential $cred
Copy-Item "$env:WORKSPACE\Package-Output\dataexporter.zip" -Destination "D:\CHART\" -ToSession $session -Recurse -Force

# Unzip dataExport.zip
Write-Host "6. Unzip dataExport.zip"
$unzip = "Expand-Archive D:\CHART\dataexporter.zip -DestinationPath D:\CHART\ -Force"
$unzipScript = [scriptblock]::Create($unzip)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ErrorAction Stop -ScriptBlock $unzipScript


# Remove dataexporter.zip file and InstallScripts after extraction
Write-Host "7. Remove Zip file after extraction"
$removeZip = "Remove-Item D:\CHART\dataexporter.zip -Recurse -Force; Remove-Item D:\CHART\InstallScripts -Recurse -Force;"
$removeZipScript = [scriptblock]::Create($removeZip)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ErrorAction Stop -ScriptBlock $removeZipScript

# Copy extracted files from EORSDataExporterService to destination
Write-Host "8. Copy extracted files to destination"
$copyExtracted = "mkdir D:\CHART\EorsDataExporter\EorsDataExporterService; Copy-Item -Force -Recurse 'D:\CHART\EORSDataExporterService\*' -Destination 'D:\CHART\EorsDataExporter\EorsDataExporterService'"
$copyExtractedScript = [scriptblock]::Create($copyExtracted)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ErrorAction Stop -ScriptBlock $copyExtractedScript

# Paste log folder to D:\CHART\EorsDataExporter\EorsDataExporterService\Logs
Write-Host "9. Copy log folder from D:Chart"
$runPasteLog = "cd; Copy-Item -Force -Recurse 'D:\CHART\Logs\*' -Destination 'D:\CHART\EorsDataExporter\EorsDataExporterService\Logs'; Remove-Item -Path 'D:\CHART\Logs' -Recurse -Force"
$runPasteLogScript = [scriptblock]::Create($runPasteLog)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ErrorAction Stop -ScriptBlock $runPasteLogScript

# Delete the files from dataexport.zip
Write-Host "10. Delete the files from dataexport.zip"
$removeFolder = "Remove-Item -Path 'D:\CHART\EORSDataExporterService' -Recurse -Force"
$removeFolderScript = [scriptblock]::Create($removeFolder)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ErrorAction Stop -ScriptBlock $removeFolderScript


# Run RegisterEorsDataExpoterService file
Write-Host "11. Run RegisterEorsDataExpoterService file"
$SERVER = [string]$env:SERVERNAME
$APP_NAME =  $SERVER.Substring(0,$SERVER.Length-1)
$APP_NAME = $APP_NAME+"app"
Write-Host $APP_NAME
$runRegister = "cd; cd D:\CHART\EorsDataExporter\InstallScripts; cmd /c RegisterEorsDataExporterService.bat $APP_NAME"
$runRegisterScript = [scriptblock]::Create($runRegister)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ErrorAction Stop -ScriptBlock $runRegisterScript

# Start EORSDataExporterService
Write-Host "12. Start EORSDataExporterService"
$startDataExporter = "`$dataExporterSer = Get-Service EORSDataExporterService -ErrorAction SilentlyContinue; `$dataExporterSer | Start-Service"
$EORSDataExporterScriptStart = [scriptblock]::Create($startDataExporter)
Invoke-command -computer $env:SERVERNAME -Credential $cred -ScriptBlock $EORSDataExporterScriptStart