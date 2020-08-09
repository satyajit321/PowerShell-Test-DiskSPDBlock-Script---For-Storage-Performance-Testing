#This script automatically calls the 64K scripts parallelly in individual PS window
#Called scripts closes after it completes
#-NoExit holds the session windows hence we can't auto proceed CSVMoves, its either this or that
#AUTHOR: Satyajit

#Setting Default startup location
cd C:\DiskSPD\TestScripts

Write-Output "Calling GroupA.ps1"
Start-Process powershell.exe  -ArgumentList "-NoExit [System.Console]::Title = 'Administrator: PS - GroupA';.\GroupA.ps1"

Write-Output "Calling GroupB.ps1"
Start-Process powershell.exe  -ArgumentList "-NoExit [System.Console]::Title = 'Administrator: PS - GroupB';.\GroupB.ps1"

Write-Output "Calling GroupC.ps1"
Start-Process powershell.exe  -ArgumentList "-NoExit [System.Console]::Title = 'Administrator: PS - GroupC';.\GroupC.ps1"

Write-Output "Calling GroupE.ps1"
date
Start-Process powershell.exe  -ArgumentList "-NoExit [System.Console]::Title = 'Administrator: PS - GroupE';.\GroupE.ps1" -Wait
date


#Use -Wait to keep the script wait until the called script completes, 
#by default it releases the control.
#Start-Process powershell.exe .\GroupE.ps1 -Wait

#Move CSV

#call again
