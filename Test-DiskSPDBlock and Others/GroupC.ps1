#70% Read / 30% Write Individual Test
#Random default , #Thread 4 default
#CAUTION -EnableGlobalAvg used make sure its reset, now MoveCSV script is resetting it.
#If called directly, remove before use or start fresh PS session everytime, else memory leak on longer sessions.

cd C:\DiskSPD\TestScripts

#Locked -ENableGlobalAvg usage on direct call from Runspace
#DEBUG: Runspace(called from console, ISE or PS);DEBUG: Internal (called from script)
Write-Debug $MyInvocation.CommandOrigin

#$iods="12 10 17 9"
$iods="17"
#$paths="C:\ClusterStorage\DiskGroupA\testfile.dat C:\ClusterStorage\DiskGroupB\testfile.dat C:\ClusterStorage\DiskGroupC\testfile.dat C:\ClusterStorage\DiskGroupE\testfile.dat"
$paths="C:\ClusterStorage\DiskGroupC\testfile.dat"

#Start Logging, temp method
$date = Get-Date -Format 'yyyy-MM-dd_hh.mm.sstt'
$name = $MyInvocation.MyCommand.Name  #ScriptName
Start-Transcript -path ".\Logs\$name`_$date.txt"

if($MyInvocation.CommandOrigin -eq 'Runspace')#Called directly from PS
{.\Test-DiskSPDBlock.ps1 -BlockSize 64K -Paths $paths -IODs $iods -Time 60 -Truns 10 -RWPercent 30
}
else #Called within a script
{.\Test-DiskSPDBlock.ps1 -BlockSize 64K -Paths $paths -IODs $iods -Time 60 -Truns 10 -RWPercent 30 #-EnableGlobalAvg
}


#List CSV placement nodes
#"SPHOST-CLUS","SPDAS"| %{Get-ClusterSharedVolume -Cluster $_}

$FormatExp = '{0,-20} {1,-20} {2,-20}'

#Table Header
$FormatExp -f "Name","OwnerNode","State"
$FormatExp -f "----","---------","-----"
"SPHOST-CLUS","SPDAS"| %{Get-ClusterSharedVolume -Cluster $_ | %{$FormatExp -f "$($_.Name)" , "$($_.OwnerNode)", "$($_.State)"}}

#Stop Logging 
Stop-Transcript