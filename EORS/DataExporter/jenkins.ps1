# Server Credentials
$SecurePassword = $env:PASSWORD | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $env:USERNAME, $SecurePassword

# Stop EORSDataExporterService
$stopDataExporter = "`$dataExporterSer = Get-Service EORSDataExporterService -ErrorAction SilentlyContinue; if (!`$dataExporterSer.HasExited) { write-host `"EORSDataExporterService is running - stopping Service`"; `$dataExporterSer | Stop-Service -Force }"
$EORSDataExporterScript = [scriptblock]::Create($stopDataExporter)
$result = $(Invoke-command -computer $env:SERVERNAME -Credential $cred -ScriptBlock $EORSDataExporterScript)

# Run RemoveEORSDataExporterService.bat file
$runRemove = "cd; cd D:\CHART\EORSDataExporterService\InstallScripts;ls; RemoveEorsDataExpoterService.bat"
$runRemoveScript = [scriptblock]::Create($runRemove)
$result1 = $(Invoke-command -computer $env:SERVERNAME -Credential $cred -ErrorAction Stop -ScriptBlock $runRemoveScript)
Write-Host $result1


# $runRemove = "Start-Process 'D:\CHART\EORSDataExporterService\InstallScripts\RemoveEorsDataExporterService.bat' -NoNewWindow -Wait"