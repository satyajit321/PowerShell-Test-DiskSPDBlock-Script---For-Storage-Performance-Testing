<#
.Synopsis
   This script uses DiskSPD.exe to test the storage and formats the output.
   Already has default values hence can be run without any parameters.
.DESCRIPTION
#AUTHOR: Satyajit
   Alter the # of threads ($threads) and I/O Depth ($iopd) below with the best results from running the other two scripts. 
   Leave the non-numeric parameter unaltered or the script will break.

$paths should be altered to reflect the network paths used in the environment. Separate different paths with only a space.
     Make sure there are no spaces in the individual paths.

$truns determines how many times the script is run before averaging the results.
$time determines how long each test is run before moving onto the next.

Parameters added are as per usage, not all diskspd paramters are exposed

23Sept2015-Imporoved formatting Shared and RW,R,W testes covered for uncluttered view. Added Consolidated Average view.

*Imporovement scopes:
 Validation, logging, output file
 Logs should have scriptname in filename.log
 Progress bar

.EXAMPLE
   Example of how to use this cmdlet
   Test-DiskSPDBlock.ps1

.EXAMPLE
help .\Test-DiskSPDBlock.ps1 -Full

There is extensive help built into this

.EXAMPLE
   Another example of how to use this cmdlet
   .\Test-DiskSPDBlock.ps1 -BlockSize 8k

.EXAMPLE
    .\Test-DiskSPDBlock.ps1 -BlockSize 8k -SeqIO -RWTest

    Starting Small-8k-SERVER-SQL-1 test on 09/10/2015 01:52:52

    50% Read/50% Write Test on C:\ClusterStorage\DiskGroupA-22x300Gb\testfile.dat at 1:52 AM
    Variables: -c100G -d1 -si -w50 -b8k -o34 -t4 -h -L 
    Run	 IOPS	    Nwk Thoroughput	 Latency	 CPU Usage
    1	 7143.24	55.81 MB/sec	 19.164 ms	 9.37% %
    2	 8519.62	66.56 MB/sec	 15.897 ms	 7.80% %
    Average - 7831.43 iops, 61.185 MB/sec, 17.5305 ms, 8.585 % CPU

    Finished Small-8k-SERVER-SQL-1 test on 09/10/2015 01:53:49

    Test duration

    Days Hours Minutes Seconds
    ---- ----- ------- -------
       0     0       0      56

.EXAMPLE
    .\Test-DiskSPDBlock.ps1 -BlockSize 8k -SeqIO -RWTest:$false

.EXAMPLE
Run all paths in one go in debug mode
    .\Test-DiskSPDBlock.ps1 -SharedTest -Debug

.EXAMPLE
With the -SharedTest switch only single -IODs is used, it warns you about it.
    .\Test-DiskSPDBlock.ps1 -SharedTest -IODs "33 22"

    Starting Large-512k-SERVER-SQL-1 test on 09/11/2015 03:39:19
    WARNING: -SharedTest, only first IOD -o33 would be used next
.EXAMPLE
If IODs are less than paths, it warns and uses default IODs for remaining paths
    .\Test-DiskSPDBlock.ps1 -Paths "C:\TestA.dat C:\TestB.dat C:\TestC.dat" -IODs "33 22"
    
    #At 3rd test you get this before the test
    WARNING: IOD count mismatch, default -o14 would be used next

.EXAMPLE
help .\Test-DiskSPDBlock.ps1 -Full
.EXAMPLE
To run all the Read, Write and Read\Write test one after other.

.\Test-DiskSPDBlock.ps1 -RWTest -ReadTest -WriteTest

50% Read/50% Write Test on C:\ClusterStorage\DiskGroupA-22x300Gb\testfile.dat at 5:02 AM
50% Read/50% Write Test on C:\ClusterStorage\DiskGroupB-10x146GB\testfile.dat at 5:03 AM

100% Read/0% Write Test on C:\ClusterStorage\DiskGroupA-22x300Gb\testfile.dat at 5:03 AM
100% Read/0% Write Test on C:\ClusterStorage\DiskGroupB-10x146GB\testfile.dat at 5:04 AM

0% Read/100% Write Test on C:\ClusterStorage\DiskGroupA-22x300Gb\testfile.dat at 5:04 AM
0% Read/100% Write Test on C:\ClusterStorage\DiskGroupB-10x146GB\testfile.dat at 5:05 AM

To run all the Read, Write and Read\Write test one after other.
.EXAMPLE
#Put this in a 512Test.ps1
-----------------------------
#50% Read / 50% Write Individual Test

$iods="35 34 18 9"
$paths="C:\ClusterStorage\DiskGroupA-22x300Gb\testfile.dat C:\ClusterStorage\DiskGroupB-10x146GB\testfile.dat C:\ClusterStorage\DiskGroupC-10x300GB\testfile.dat C:\ClusterStorage\DiskGroupE-6x400Gb\testfile.dat"

.\Test-DiskSPDBlock.ps1 -Paths $paths -IODs $iods
-----------------------------
.EXAMPLE
.EXAMPLE
.EXAMPLE
.EXAMPLE
.EXAMPLE
.EXAMPLE

#>
#function Verb-Noun
#{
    [CmdletBinding()]
    #[OutputType([int])]
    Param
    (

        #Total Runs\Tests Loops
        [int]$Truns=10,

        #Time in seconds for single test
        $Time = 60,
        $Threads=4,

        #Test File <size>[K|M|G|b]
        $Size="100G",

        #Block size <size>[K|M|G], 512k,8k are common    
        $BlockSize = "512k",

        #TargetPaths- Multi-Valued space seperated, by default current path is taken
        #"C:\Testfile.dat D:\Testfile2.dat"
        $Paths = "testfile.dat",
        
        #Outstanding IO Depth - Multi-Valued space seperated,defaulted -o14 later
        # "-o35 -o34 -o18 -o9"
        [string[]]$IODs="", 

        #RW test percent R=100-W, this is Write %
        $RWPercent = 50,


        #Test random\seq I/O - Default is Random, default stride size=block size,
        [switch]$SeqIO,
       
        #Enable $Global:OutAvg variable, Avg. results can be accessed outside this script.
        #Keeping it open will lead to memory leak, when used make sure calling script has [string[]]$Global:OutAvg = ""
        #Also it needs to be explicitly called $Global:OutAvg to display the contents.
        #Use this if($MyInvocation.CommandOrigin -eq 'Runspace')#Called directly from PS
        [switch]$EnableGlobalAvg,

        ##Type of tests to cover

            #"100% Write Test on "  + (Get-date).ToShortTimeString() -w100
            [switch]$ReadTest,

            #"100% Read Test on "  + (Get-date).ToShortTimeString() -w0
            [switch]$WriteTest,

            #Default 50%ReadWrite test runs
            [switch]$RWTest=$true,

            

            # Fine tuning script for Large512K and Small8k scripts
            #Automatically sets few values for testing
            #512K, 4 thread, 8k 8thd, d15,truns 45, looping IOD -o 1..45
            [switch]$FineTuning,

            #Use this switch to use the $paths as a single test.Default is individual unlike DiskSPD
            [switch]$SharedTest
        
    )


#}

##Preping the variables
    $time= "-d$time" #"-d4320" 1.2hrs#"-d900" 15mins, totalscript 10hrs
    $threads="-t$threads"
    $size="-c$size"
    $BlockSz = "-b$BlockSize"
     #Deciding Block size is Large or Small
    $Large = if([int]$($BlockSize.ToUpper().Trim("G","M","K","B")) -gt 256){"Large"}else{"Small"}
    Write-Debug "BlockSize: $Large" 
    $date1=date
    $Server = $env:COMPUTERNAME
    
    #Selecting IO test , -r overrides -s or -si
    $SeqRand = if($SeqIO){"-si"}else{"-r"}

    #Sample Input for testing##########
    #outstanding I/O requests per target per thread
    #$iods="35"# 34"#-o18 -o9"
    #$iods="35 34 18 9"
    #$paths="C:\ClusterStorage\DiskGroupA-22x300Gb\testfile.dat C:\ClusterStorage\DiskGroupB-10x146GB\testfile.dat C:\ClusterStorage\DiskGroupC-10x300GB\testfile.dat C:\ClusterStorage\DiskGroupE-6x400Gb\testfile.dat"

    #If $paths ="" then $size ="-c1G" $path ="testfile.dat"

    #Used for mismatch cases
    $iodDefault = "14"

    #Use Default if no IOD  input, made it array to handle some errors
    if($iods[0] -eq ""){$IODIsDefault = $true}else{$IODIsDefault = $False}

    Write-Debug  "IODIsDefault: $IODIsDefault"
    #Split required; be it shared or individual threads across targets, else diskspd crashes
    $iods = $iods.trim().Split(" ")
    $paths = $paths.trim().split(" ")


    Write-Debug "`n$paths`n IODs: $iods"

    #The formatter expression,{x,-y} minus = left alignment
    $FormatExp = '{0,-10} {1,-10} {2,-20} {3,-13} {4,-8}'

    
    

#No. of sections where $truns is used, helps in progress bar
    #Set it 1 for progress for individual sections
    $sec = 4

#Progess bar counter
$iprog = 0 

#Start Logging, this should ideally not inside the script
#Start-Transcript -OutputDirectory ".\Logs-temp\"

<#
# Create Log File for Write-Log Function
Function Create-Log()
{
	$datena = Get-Date -Format 'yyyy-MM-dd hh-mm-ss tt'
              #Get-Date -Format 'yyyy-MM-dd_hh.mm.sstt'
	$global:LogFile = New-Item -Itemtype file "$PWD\ReadOnlyPermissions-$mailbox-$date.log" -Force
}

# Call Function to create logfile
Create-Log

# Output to the screen and to the logfile

Function Write-Log($txt)
{
 	Add-Content $global:LogFile $txt
 	Write-Host $txt -ForegroundColor Green
}
#>

Write-Output "`nStarting $Large-$BlockSize-$Server test on $($date1.ToString('dddd, MMMM dd, yyyy hh:mm:ss tt'))"



###Code Starts for running test###SubFunction######
function Start-Tests{


#Resetting incase $sec is incorrectly mentioned
#if(($iprog/($truns*$sec)*100) -ge 100){$iprog = 0 }  


#Getting respective IOD values, adding -o formatting
if(($iods.Count -gt $i) -and (-not $IODIsDefault)) 
{
    $iopd="-o$($iods[$i])"
    
    #Generating Warning for extra IODs
    if($SharedTest -and ($iods.Count -gt 1))
        {#Write-Warning "-SharedTest, only first IOD $iopd would be used next"
        Write-Output "WARNING: -SharedTest, only first IOD $iopd would be used next"
        }
    else
        {#Scope is going outside func,script when in loop
        $global:i++}

}
elseif($IODIsDefault) #Considering blank IOD input
{
    $iopd= "-o$iodDefault"
}
else #Non-Shared test, More paths than -o defined, use default
{
    $iopd= "-o$iodDefault"
    "`n"
    #Write-Warning "IOD count mismatch, default $iopd would be used next"
    Write-Output "WARNING: IOD count mismatch, default $iopd would be used next"
    
}

    Write-Debug "IOD $iopd"



# Do NOT alter the below variables, if changed the reported results will be skewed! #
$runs=1
$tiops=0
$tmbps=0
$tlatency=0 
$tcpu=0
$aiops=0
$ambps=0
$alatency=0 
$acpu=0



Write-Output "`n`n$(100-$RWPercent)% Read/$RWPercent% Write Test on $path at $((Get-date).ToShortTimeString())"

#Value coming from outside func scope
$RWPercent =  "-w$RWPercent"

Write-Output "`nVariables: $size $time $SeqRand $RWPercent $BlockSz $iopd $threads -h -L $path"
#Use hashtable or PSObject here or custom formatting as display is uncertain
#Write-Output "Run	 IOPS	    Nwk Thoroughput	 Latency	 CPU Usage"

""
#Table Header
$FormatExp -f "Run","IOPS","Throughput(MB/sec)","Latency(ms)","CPU(%)"
$FormatExp -f "---","-----","------------------","-----------","------"

# TEST CYCLE CODE #
1..$truns | % { 

 #Showing Progress based on the input data object count
  # write-progress -activity "Storage Testing" -status "Progress:" -percentcomplete ($iprog/($truns*$sec)*100)
   #$iprog++

   # x86fre amd64fre
   #$result = C:\DiskSPD\x86fre\diskspd.exe $size $time $SeqRand $RWPercent $BlockSz $iopd $threads -h -L $path
   $result = C:\DiskSPD\amd64fre\diskspd.exe $size $time $SeqRand $RWPercent $BlockSz $iopd $threads -h -L $path
   foreach ($line in $result) {if ($line -like "total:*") { $total=$line; break } }
   foreach ($line in $result) {if ($line -like "avg.*") { $avg=$line; break } }
   $mbps = $total.Split("|")[2].Trim() 
   $iops = $total.Split("|")[3].Trim()
   $latency = $total.Split("|")[4].Trim()
   $cpu = $avg.Split("|")[1].Trim(" ","%")

# REPORTING RESULTS #
   #Write-Output "$runs	 $iops	$mbps MB/sec	 $latency ms	 $cpu %"
   $FormatExp -f $runs,$iops,$mbps,$latency,$cpu

   $runs+=1
   $tiops+=$iops
   $tmbps+=$mbps 
   $tlatency+=$latency 
   $tcpu+=$cpu
}

# AVERAGING RESULTS CODE #
$aiops = $tiops / $truns 
$ambps = $tmbps / $truns 
$alatency = $tlatency / $truns
$acpu = $tcpu / $truns 
#Write-Output “Average - $aiops iops, $ambps MB/sec, $alatency ms, $acpu % CPU"
$FormatExp -f "---","--------","------","-------","-----"
$FormatExp -f "Average",$aiops,$ambps,$alatency,$acpu


#Accumulating Avg. to display later
$script:Avg += $FormatExp -f $($script:Avg.Count-1),$aiops,$ambps,$alatency,$acpu

 
}
###Code Ends for running test#########

#Deciding Shared Test or individual paths and Start-Test######Sub Call
function Check-Shared
{

#Keeping track of index to match IOD with path, #Scope is going outside func,script
$global:i = 0

#Header and reset
[string[]]$script:Avg = $FormatExp -f "Path","IOPS","Throughput(MB/sec)","Latency(ms)","CPU(%)"
$script:Avg += $FormatExp -f "----","----","------------------","-----------","------"
           
    if(-not ($SharedTest))
    {
        Write-Debug "SharedTest: $SharedTest"

        ForEach ($path in $paths)
        {
        #Calling function to start tests with individual paths
        Start-Tests
        }#For $Paths
    }
    else #SharedTest
    {

        $path=$Paths
        #Calling function to start tests with all paths together
        Write-Output "`nSharedTest: $SharedTest"
        Start-Tests
    }

}#Start-Test######Sub Call Ends##############



#Selecting the Tests to run##################Main Call

#Consolidated Average Results
[string[]]$AvgTot = ""

if($RWTest)
{
    #Default Write percent 50, remaining read - 50%
    #$RWPercent = "50"

    $AvgTot += "`nRead\Write Test Average:"

    Check-Shared
    
    $AvgTot += $script:Avg
}

if($ReadTest)
{
    #Write percent 0, remaining read - 100%
    $RWPercent = "0"

    $AvgTot += "`nRead Test Average:"
    
    Check-Shared
    
    $AvgTot += $script:Avg
}

if($WriteTest)
{
    #Write percent 100, remaining read - 0%
    $RWPercent = "100"
    
    $AvgTot += "`nWrite Test Average:"
    
    Check-Shared
    
    $AvgTot += $script:Avg
}


$date2=date
Write-Output "`nFinished $Large-$BlockSize-$Server test on $($date2.ToString('dddd, MMMM dd, yyyy hh:mm:ss tt'))"

#"`n"
#Display Average Results of the script
$AvgTot


#This can be used to get the output across scripts per session
if($EnableGlobalAvg) #Keeping it open will lead to memory leak
{[string[]]$Global:OutAvg += $AvgTot}

#Duration of the test - TimeSpan
$diff = $date2-$date1
Write-Output "`n`nTest duration: $($Diff.Days)days $($Diff.Hours)hrs $($Diff.Minutes)mins and $($Diff.Seconds)secs`n`n"

#Stop Logging , this should ideally not inside the script
#Stop-Transcript