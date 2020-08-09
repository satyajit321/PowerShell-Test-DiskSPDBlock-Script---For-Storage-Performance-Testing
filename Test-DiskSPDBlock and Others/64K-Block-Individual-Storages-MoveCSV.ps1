#This script automatically moves the CSVs nodes and tests DiskSPD
#AUTHOR: Satyajit


#Setting Default startup location
cd C:\DiskSPD\TestScripts

#Breaks between CSV moves and testing
Function SleepHere{
$sleepT = (60*2)
Write-Host "`nSleeping for $sleepT secs at $(date) " -NoNewline ; Start-Sleep $sleepT; Write-Output " Resuming at $(date)"
}

#Moves are | Out-Null, due to formatting issue. Unhandled formatting
#Try Out-String -Stream

#Start time
$date1=date


#Resetting Global Avg variable, available inside Test-DiskSPD
[string[]]$Global:OutAvg = ""

#1 – Split VDs
    #50\50 split - 1,2,1,2
    Write-Output "`n##########Splitting VDs - Node 1,2,1,2##########"
    1..4 | %{if($_%2 -eq 1){Get-ClusterSharedVolume -Cluster SPDAS -Name "Cluster Disk $_"| Move-ClusterSharedVolume -Node SERVER-SQL-1}else{Get-ClusterSharedVolume -Cluster SPDAS -Name "Cluster Disk $_"| Move-ClusterSharedVolume -Node SERVER-SQL-2  | Out-Null}}
    1..4 | %{if($_%2 -eq 1){Get-ClusterSharedVolume -Cluster SERVER-CLUS -Name "Cluster Disk $_"| Move-ClusterSharedVolume -Node SERVER-HOST-1}else{Get-ClusterSharedVolume -Cluster SERVER-CLUS -Name "Cluster Disk $_"| Move-ClusterSharedVolume -Node SERVER-HOST-2 | Out-Null}}
    

    #Consolidating results
    $Global:OutAvg += "`n##########Splitting VDs - Node 1,2,1,2##########"

    SleepHere

    #Run the test:
    .\64K-Block-Individual-Storages.ps1
    
    #Letting the system cool down
    SleepHere

#2 – Switch the VDs to the opposing HOST (split VDs)
    #Move specific CSVs to Best Possible Node or SWAP
    Write-Output "`n`n`n##########Switching the VDs to the opposing HOST (split VDs)##########"
    1..4 |%{Get-ClusterSharedVolume -Cluster SPDAS -Name "Cluster Disk $_" | Move-ClusterSharedVolume | Out-Null }
    1..4 |%{Get-ClusterSharedVolume -Cluster SERVER-CLUS -Name "Cluster Disk $_" | Move-ClusterSharedVolume | Out-Null }

    #Consolidating results
    $Global:OutAvg += "`n`n`n##########Switching the VDs to the opposing HOST (split VDs)##########"
    SleepHere

    #Run the test:
    .\64K-Block-Individual-Storages.ps1

    #Letting the system cool down
    SleepHere

#3 – All VDs assigned to SERVER-HOST-1
    ##VM1+HOST1
    Write-Output "`n`n`n##########All VDs assigned to SERVER-HOST-1,SERVER-SQL-1##########"
    1..4 |%{Get-ClusterSharedVolume -Cluster SPDAS -Name "Cluster Disk $_" | Move-ClusterSharedVolume -Node SERVER-SQL-1| Out-Null}
    1..4 |%{Get-ClusterSharedVolume -Cluster SERVER-CLUS -Name "Cluster Disk $_" | Move-ClusterSharedVolume -Node SERVER-HOST-1| Out-Null}

    #Consolidating results
    $Global:OutAvg += "`n`n`n##########All VDs assigned to SERVER-HOST-1,SERVER-SQL-1##########"

    SleepHere

    #Run the test:
    .\64K-Block-Individual-Storages.ps1

    #Letting the system cool down
    SleepHere

#4 – All VDs assigned to SERVER-HOST-2
    ##VM2+Host2 or Use SWAP
    Write-Output "`n`n`n##########All VDs assigned to SERVER-HOST-2,SERVER-SQL-2##########"
    1..4 |%{Get-ClusterSharedVolume -Cluster SPDAS -Name "Cluster Disk $_" | Move-ClusterSharedVolume -Node SERVER-SQL-2 | Out-Null}
    1..4 |%{Get-ClusterSharedVolume -Cluster SERVER-CLUS -Name "Cluster Disk $_" | Move-ClusterSharedVolume -Node SERVER-HOST-2| Out-Null}

    #Consolidating results
    $Global:OutAvg +=  "`n`n`n##########All VDs assigned to SERVER-HOST-2,SERVER-SQL-2##########"

    SleepHere

    #Run the test:
    .\64K-Block-Individual-Storages.ps1

#Total Global Average Results
Write-Output "`n`nTotal Average Results:"
$Global:OutAvg

#End Time
$date2=date

#Duration of the test - TimeSpan
$diff = $date2-$date1
Write-Output "`nTotal Test duration: $($Diff.Days)days $($Diff.Hours)hrs $($Diff.Minutes)mins and $($Diff.Seconds)secs`n"