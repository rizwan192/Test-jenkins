$dataExporterSer = Get-Service EORSDataExporterService -ErrorAction SilentlyContinue
if (!$dataExporterSer.HasExited) {
     write-host "EORSDataExporterService is running - stopping Service"; 
     $dataExporterSer | Stop-Service -Force 
}


