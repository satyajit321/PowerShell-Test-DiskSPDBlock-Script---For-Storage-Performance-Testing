<# Fine tuning script for Large512K,Small64K and Small8k scripts 
Doesn't create the testfiles.dat, need to run other script first.
#70% read /30%write
#Random
#Formatting Improved, Suggests best IOPS
#AUTHOR: Satyajit
#>

#Delayed Start secs
#Start-Sleep $(30*15)

#Start Logging, temp method
$date = Get-Date -Format 'yyyy-MM-dd_hh.mm.sstt'
$name = $MyInvocation.MyCommand.Name  #ScriptName
Start-Transcript -path ".\Logs\$name`_$date.txt"


#Declaring the parameters
$para1 = "IOD"
$para2 = "IOPS"
$para3 = "Throughput_MBps"
$para4 = "Latency_ms"
$para5 = "CPU_%"


#StorageObjectTemplate
$StorageObj = New-Object –TypeName PSObject -Property @{
    $para1 = ""
    $para2 = ""
    $para3 = ""
    $para4 = ""
    $para5 = ""
  }

#Input paths
$paths="C:\ClusterStorage\DiskGroupA\testfile.dat C:\ClusterStorage\DiskGroupB\testfile.dat C:\ClusterStorage\DiskGroupC\testfile.dat C:\ClusterStorage\DiskGroupE\testfile.dat"
$paths = $paths.split(" ")

$date1=date
$date1

#The formatter expression {<index>,<longest value including header>} also gap between '{} {}' is required
#{x,-y} minus = left alignment
$FormatExp = '{0,-3} {1,-10} {2,-17} {3,-11} {4,-8}'
        

#Looping individual paths
foreach ($path in $paths)
{
<#Variables. truns = Total Runs, Runs = Current test cycle#>
$truns=45
$time = "-d15"
$runs=1
$date2=date

#$path = "C:\ClusterStorage\DiskGroupA\testfile.dat"


#Creating Blank array for holding the result
$objResult = @()

"Small 64K, 4 thread starting on $path $date2"
"Variables: -d15 -r -w30 -t4 -b64K -h -L" # Manual paste of $result changes
#"IOD   IOPS    Nwk Throughput Latency   CPU Usage"
""
#Table Header
$FormatExp -f "IOD","IOPS","Throughput_MBps","Latency_ms","CPU_%"

1..$truns | % {  
   $param = "-o $_"
   #$result = C:\DiskSPD\x86fre\diskspd.exe $time -r -w30 -t4 $param -b64K -h -L $path
   $result = C:\DiskSPD\amd64fre\diskspd.exe $time -r -w30 -t4 $param -b64K -h -L $path
   foreach ($line in $result) {if ($line -like "total:*") { $total=$line; break } }
   foreach ($line in $result) {if ($line -like "avg.*") { $avg=$line; break } }
   $mbps = $total.Split("|")[2].Trim() 
   $iops = $total.Split("|")[3].Trim()
   $latency = $total.Split("|")[4].Trim()
   $cpu = $avg.Split("|")[1].Trim(" ","%")
   #"$runs     $iops  $mbps MB/sec  $latency ms  $cpu%"

    #Creating new object for every item using template
     $objTemp = $StorageObj | Select-Object *


    #Assigning values to the object
     $objTemp.$para1 = $runs
     $objTemp.$para2 = $iops
     $objTemp.$para3 = $mbps
     $objTemp.$para4 = $latency
     $objTemp.$para5 = $cpu
     
     #List values
     $FormatExp -f $objTemp.IOD,$objTemp.IOPS,$objTemp.Throughput_MBps,$objTemp.Latency_ms,$objTemp.'CPU_%'

    #Assigning the obj into the array and incrementing
     $objResult += $objTemp

   $runs+=1
   }

   #List out the values
   # $objResult | ft IOD,IOPS,Throughput_MBps,Latency_ms,CPU_% -AutoSize

   #Export-Csv

   #Sorting and filtering Starts
    #Limits on Latency and CPU
    $lt = 20
    $cp = 30

    ""
    
    "Suggested Group Only Latency < $lt limit:"
    $objResult | ?{[float]$_.Latency_ms -lt $lt} | Sort-Object {[float] $_.IOPS} -Descending |
     Select-Object -First 3 | ft IOD,IOPS,Throughput_MBps,Latency_ms,CPU_% -AutoSize

    "Suggested Group Latency < $lt and CPU < $cp limit:"
    $objResult | ?{([float]$_.Latency_ms -lt $lt) -and ([float]$_.'CPU_%'-lt $cp)} | Sort-Object {[float] $_.IOPS} -Descending | 
     Select-Object -First 3 | ft IOD,IOPS,Throughput_MBps,Latency_ms,CPU_% -AutoSize
   #Sorting and Filtering Ends


"Small 64K, 4 thread ending"
" "
}
# Calculates test duration #
$date3 = date
$date3

"Test duration"
$date3 - $date1 | ft Days,Hours,Minutes,Seconds

#Stop Logging 
Stop-Transcript
