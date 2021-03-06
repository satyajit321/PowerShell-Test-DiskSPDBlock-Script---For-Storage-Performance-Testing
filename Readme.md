<p>&nbsp;</p>
<h1>Introduction</h1>
<p>These scripts are implementation of DiskSPD.exe storage performance testing using PowerShell.</p>
<p>The bundle consists of total of 5 scripts, which serves different testing scenarios and requirements.</p>
<p>Scripts are:</p>
<ol>
<li>Test-DiskSPDBlock.ps1 </li>
<li>Finetuning-Individual-Storages.ps1 </li>
<li>64K-Block-Individual-Storages.ps1 </li>
<li>64K-Block-Individual-Storages-Parallel.ps1 <ol>
<li>GroupA.ps1 </li>
<li>GroupB.ps1 </li>
<li>GroupC.ps1 </li>
<li>GroupE.ps1 </li>
</ol> </li>
<li>64K-Block-Individual-Storages-MoveCSV.ps1 </li>
</ol>
<p>&nbsp;</p>
<p>Don&rsquo;t go by the 64K name, it&rsquo;s basically named due to the<br /> 64k block size value used in the scripts. It can be anything else like 8k, 512k<br /> etc.</p>
<p>These scripts are more focused on testing DAS Storage<br /> targeted for SharePoint SQL server deployments. But can be used for any other<br /> solution, due to the fact being the test doesn&rsquo;t require you to have any SQL<br /> Server pre-installed and it&rsquo;s directly on Windows Server with storages<br /> configured.</p>
<p>In the core it uses DiskSpd.exe a tool from Microsoft for<br /> storage testing. The <a href="http://blogs.technet.com/b/josebda/archive/2014/10/13/diskspd-powershell-and-storage-performance-measuring-iops-throughput-and-latency-for-both-local-disks-and-smb-file-shares.aspx"> DiskSPD<br /> basics\functionality</a> remains same. The script is more of customization and<br /> automation using the common inputs and outputs. Makes using otherwise messy<br /> DiskPSD a breeze.</p>
<p>By Default the script expects to find DiskSPD.exe with all<br /> its components at this location (Can be modified).</p>
<p><strong>C:\DiskSPD\amd64fre\diskspd.exe&nbsp;; C:\DiskSPD</strong></p>
<p>To get started, you need to download and install the<br /> DiskSpd. You can get the tool from <a href="http://aka.ms/DiskSpd">http://aka.ms/DiskSpd</a>.</p>
<p>You&rsquo;ll download a ZIP file that contains separate folders for three versions of DiskSpd: amd64fre<br /> (for 64-bit systems), x86fre (for 32-bit systems) and armfre (for ARM systems).<br /> <strong>To run a test on a server running<br /> Windows Server 2012 R2, you only need to download the amd64fre folder.</strong></p>
<ul>
<li>Some of the scripts have &lsquo;Default startup<br /> location setting&rsquo; and expected script location is this: </li>
</ul>
<p><strong>cd C:\DiskSPD\TestScripts</strong></p>
<ul>
<li><br /> The *Block-Individual-*.ps1 and Group*.ps1 scripts<br /> have usage of #Get-ClusterSharedVolume, should be commented # if Failover<br /> Cluster is not in use. </li>
</ul>
<p>IMPORTANT: - The PowerShell Session should be &lsquo;Run as administrator&rsquo;. Otherwise you would see strange errors and crashes.</p>
<p>&nbsp;</p>
<div class="scriptcode">
<div class="pluginEditHolder" pluginCommand="mceScriptCode">
<div class="title"><span>PowerShell</span></div>
<div class="pluginLinkHolder"><span class="pluginEditHolderLink">Edit</span>|<span class="pluginRemoveHolderLink">Remove</span></div>
<span class="hidden">powershell</span>
<pre class="hidden">.EXAMPLE
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
-----------------------------</pre>
<div class="preview">
<pre class="powershell">.EXAMPLE&nbsp;
&nbsp;&nbsp;&nbsp;Example&nbsp;of&nbsp;how&nbsp;to&nbsp;use&nbsp;this&nbsp;cmdlet&nbsp;
&nbsp;&nbsp;&nbsp;Test<span class="powerShell__operator">-</span>DiskSPDBlock.ps1&nbsp;
&nbsp;
.EXAMPLE&nbsp;
help&nbsp;.\Test<span class="powerShell__operator">-</span>DiskSPDBlock.ps1&nbsp;<span class="powerShell__operator">-</span>Full&nbsp;
&nbsp;
There&nbsp;is&nbsp;extensive&nbsp;help&nbsp;built&nbsp;into&nbsp;this&nbsp;
&nbsp;
.EXAMPLE&nbsp;
&nbsp;&nbsp;&nbsp;Another&nbsp;example&nbsp;of&nbsp;how&nbsp;to&nbsp;use&nbsp;this&nbsp;cmdlet&nbsp;
&nbsp;&nbsp;&nbsp;.\Test<span class="powerShell__operator">-</span>DiskSPDBlock.ps1&nbsp;<span class="powerShell__operator">-</span>BlockSize&nbsp;8k&nbsp;
&nbsp;
.EXAMPLE&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;.\Test<span class="powerShell__operator">-</span>DiskSPDBlock.ps1&nbsp;<span class="powerShell__operator">-</span>BlockSize&nbsp;8k&nbsp;<span class="powerShell__operator">-</span>SeqIO&nbsp;<span class="powerShell__operator">-</span>RWTest&nbsp;
&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;Starting&nbsp;Small<span class="powerShell__operator">-</span>8k<span class="powerShell__operator">-</span>SERVER<span class="powerShell__operator">-</span>SQL<span class="powerShell__operator">-</span>1&nbsp;test&nbsp;on&nbsp;09<span class="powerShell__operator">/</span>10<span class="powerShell__operator">/</span>2015&nbsp;01:52:52&nbsp;
&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;50%&nbsp;Read<span class="powerShell__operator">/</span>50%&nbsp;Write&nbsp;Test&nbsp;on&nbsp;C:\ClusterStorage\DiskGroupA<span class="powerShell__operator">-</span>22x300Gb\testfile.dat&nbsp;at&nbsp;1:52&nbsp;AM&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;Variables:&nbsp;<span class="powerShell__operator">-</span>c100G&nbsp;<span class="powerShell__operator">-</span>d1&nbsp;<span class="powerShell__operator">-</span><span class="powerShell__alias">si</span>&nbsp;<span class="powerShell__operator">-</span>w50&nbsp;<span class="powerShell__operator">-</span>b8k&nbsp;<span class="powerShell__operator">-</span>o34&nbsp;<span class="powerShell__operator">-</span>t4&nbsp;<span class="powerShell__operator">-</span><span class="powerShell__alias">h</span>&nbsp;<span class="powerShell__operator">-</span>L&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;Run&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;IOPS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nwk&nbsp;Thoroughput&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Latency&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CPU&nbsp;Usage&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;7143.24&nbsp;&nbsp;&nbsp;&nbsp;55.81&nbsp;MB<span class="powerShell__operator">/</span>sec&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;19.164&nbsp;ms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;9.37%&nbsp;%&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;8519.62&nbsp;&nbsp;&nbsp;&nbsp;66.56&nbsp;MB<span class="powerShell__operator">/</span>sec&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;15.897&nbsp;ms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;7.80%&nbsp;%&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;Average&nbsp;<span class="powerShell__operator">-</span>&nbsp;7831.43&nbsp;iops,&nbsp;61.185&nbsp;MB<span class="powerShell__operator">/</span>sec,&nbsp;17.5305&nbsp;ms,&nbsp;8.585&nbsp;%&nbsp;CPU&nbsp;
&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;Finished&nbsp;Small<span class="powerShell__operator">-</span>8k<span class="powerShell__operator">-</span>SERVER<span class="powerShell__operator">-</span>SQL<span class="powerShell__operator">-</span>1&nbsp;test&nbsp;on&nbsp;09<span class="powerShell__operator">/</span>10<span class="powerShell__operator">/</span>2015&nbsp;01:53:49&nbsp;
&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;Test&nbsp;duration&nbsp;
&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;Days&nbsp;Hours&nbsp;Minutes&nbsp;Seconds&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;<span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span>&nbsp;<span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span>&nbsp;<span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span>&nbsp;<span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span>&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;56&nbsp;
&nbsp;
.EXAMPLE&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;.\Test<span class="powerShell__operator">-</span>DiskSPDBlock.ps1&nbsp;<span class="powerShell__operator">-</span>BlockSize&nbsp;8k&nbsp;<span class="powerShell__operator">-</span>SeqIO&nbsp;<span class="powerShell__operator">-</span>RWTest:<span class="powerShell__variable">$false</span>&nbsp;
&nbsp;
.EXAMPLE&nbsp;
Run&nbsp;all&nbsp;paths&nbsp;<span class="powerShell__keyword">in</span>&nbsp;one&nbsp;go&nbsp;<span class="powerShell__keyword">in</span>&nbsp;debug&nbsp;mode&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;.\Test<span class="powerShell__operator">-</span>DiskSPDBlock.ps1&nbsp;<span class="powerShell__operator">-</span>SharedTest&nbsp;<span class="powerShell__operator">-</span>Debug&nbsp;
&nbsp;
.EXAMPLE&nbsp;
With&nbsp;the&nbsp;<span class="powerShell__operator">-</span>SharedTest&nbsp;<span class="powerShell__keyword">switch</span>&nbsp;only&nbsp;single&nbsp;<span class="powerShell__operator">-</span>IODs&nbsp;is&nbsp;used,&nbsp;it&nbsp;warns&nbsp;you&nbsp;about&nbsp;it.&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;.\Test<span class="powerShell__operator">-</span>DiskSPDBlock.ps1&nbsp;<span class="powerShell__operator">-</span>SharedTest&nbsp;<span class="powerShell__operator">-</span>IODs&nbsp;<span class="powerShell__string">"33&nbsp;22"</span>&nbsp;
&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;Starting&nbsp;Large<span class="powerShell__operator">-</span>512k<span class="powerShell__operator">-</span>SERVER<span class="powerShell__operator">-</span>SQL<span class="powerShell__operator">-</span>1&nbsp;test&nbsp;on&nbsp;09<span class="powerShell__operator">/</span>11<span class="powerShell__operator">/</span>2015&nbsp;03:39:19&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;WARNING:&nbsp;<span class="powerShell__operator">-</span>SharedTest,&nbsp;only&nbsp;first&nbsp;IOD&nbsp;<span class="powerShell__operator">-</span>o33&nbsp;would&nbsp;be&nbsp;used&nbsp;next&nbsp;
.EXAMPLE&nbsp;
<span class="powerShell__keyword">If</span>&nbsp;IODs&nbsp;are&nbsp;less&nbsp;than&nbsp;paths,&nbsp;it&nbsp;warns&nbsp;and&nbsp;uses&nbsp;default&nbsp;IODs&nbsp;<span class="powerShell__keyword">for</span>&nbsp;remaining&nbsp;paths&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;.\Test<span class="powerShell__operator">-</span>DiskSPDBlock.ps1&nbsp;<span class="powerShell__operator">-</span>Paths&nbsp;<span class="powerShell__string">"C:\TestA.dat&nbsp;C:\TestB.dat&nbsp;C:\TestC.dat"</span>&nbsp;<span class="powerShell__operator">-</span>IODs&nbsp;<span class="powerShell__string">"33&nbsp;22"</span>&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;<span class="powerShell__com">#At&nbsp;3rd&nbsp;test&nbsp;you&nbsp;get&nbsp;this&nbsp;before&nbsp;the&nbsp;test</span>&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;WARNING:&nbsp;IOD&nbsp;count&nbsp;mismatch,&nbsp;default&nbsp;<span class="powerShell__operator">-</span>o14&nbsp;would&nbsp;be&nbsp;used&nbsp;next&nbsp;
&nbsp;
.EXAMPLE&nbsp;
help&nbsp;.\Test<span class="powerShell__operator">-</span>DiskSPDBlock.ps1&nbsp;<span class="powerShell__operator">-</span>Full&nbsp;
.EXAMPLE&nbsp;
To&nbsp;run&nbsp;all&nbsp;the&nbsp;Read,&nbsp;Write&nbsp;and&nbsp;Read\Write&nbsp;test&nbsp;one&nbsp;after&nbsp;other.&nbsp;
&nbsp;
.\Test<span class="powerShell__operator">-</span>DiskSPDBlock.ps1&nbsp;<span class="powerShell__operator">-</span>RWTest&nbsp;<span class="powerShell__operator">-</span>ReadTest&nbsp;<span class="powerShell__operator">-</span>WriteTest&nbsp;
&nbsp;
50%&nbsp;Read<span class="powerShell__operator">/</span>50%&nbsp;Write&nbsp;Test&nbsp;on&nbsp;C:\ClusterStorage\DiskGroupA<span class="powerShell__operator">-</span>22x300Gb\testfile.dat&nbsp;at&nbsp;5:02&nbsp;AM&nbsp;
50%&nbsp;Read<span class="powerShell__operator">/</span>50%&nbsp;Write&nbsp;Test&nbsp;on&nbsp;C:\ClusterStorage\DiskGroupB<span class="powerShell__operator">-</span>10x146GB\testfile.dat&nbsp;at&nbsp;5:03&nbsp;AM&nbsp;
&nbsp;
100%&nbsp;Read<span class="powerShell__operator">/</span>0%&nbsp;Write&nbsp;Test&nbsp;on&nbsp;C:\ClusterStorage\DiskGroupA<span class="powerShell__operator">-</span>22x300Gb\testfile.dat&nbsp;at&nbsp;5:03&nbsp;AM&nbsp;
100%&nbsp;Read<span class="powerShell__operator">/</span>0%&nbsp;Write&nbsp;Test&nbsp;on&nbsp;C:\ClusterStorage\DiskGroupB<span class="powerShell__operator">-</span>10x146GB\testfile.dat&nbsp;at&nbsp;5:04&nbsp;AM&nbsp;
&nbsp;
0%&nbsp;Read<span class="powerShell__operator">/</span>100%&nbsp;Write&nbsp;Test&nbsp;on&nbsp;C:\ClusterStorage\DiskGroupA<span class="powerShell__operator">-</span>22x300Gb\testfile.dat&nbsp;at&nbsp;5:04&nbsp;AM&nbsp;
0%&nbsp;Read<span class="powerShell__operator">/</span>100%&nbsp;Write&nbsp;Test&nbsp;on&nbsp;C:\ClusterStorage\DiskGroupB<span class="powerShell__operator">-</span>10x146GB\testfile.dat&nbsp;at&nbsp;5:05&nbsp;AM&nbsp;
&nbsp;
To&nbsp;run&nbsp;all&nbsp;the&nbsp;Read,&nbsp;Write&nbsp;and&nbsp;Read\Write&nbsp;test&nbsp;one&nbsp;after&nbsp;other.&nbsp;
.EXAMPLE&nbsp;
<span class="powerShell__com">#Put&nbsp;this&nbsp;in&nbsp;a&nbsp;512Test.ps1</span>&nbsp;
<span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span>&nbsp;
<span class="powerShell__com">#50%&nbsp;Read&nbsp;/&nbsp;50%&nbsp;Write&nbsp;Individual&nbsp;Test</span>&nbsp;
&nbsp;
<span class="powerShell__variable">$iods</span>=<span class="powerShell__string">"35&nbsp;34&nbsp;18&nbsp;9"</span>&nbsp;
<span class="powerShell__variable">$paths</span>=<span class="powerShell__string">"C:\ClusterStorage\DiskGroupA-22x300Gb\testfile.dat&nbsp;C:\ClusterStorage\DiskGroupB-10x146GB\testfile.dat&nbsp;C:\ClusterStorage\DiskGroupC-10x300GB\testfile.dat&nbsp;C:\ClusterStorage\DiskGroupE-6x400Gb\testfile.dat"</span>&nbsp;
&nbsp;
.\Test<span class="powerShell__operator">-</span>DiskSPDBlock.ps1&nbsp;<span class="powerShell__operator">-</span>Paths&nbsp;<span class="powerShell__variable">$paths</span>&nbsp;<span class="powerShell__operator">-</span>IODs&nbsp;<span class="powerShell__variable">$iods</span>&nbsp;
<span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span><span class="powerShell__operator">-</span></pre>
</div>
</div>
</div>
<div class="endscriptcode">&nbsp;</div>
<p>&nbsp;</p>
<p><br /> <strong>Read the full detailed explaination&nbsp;on the attached document:</strong></p>
<p><strong><a id="145130" href="/site/view/file/145130/1/Test-DiskSPDBlock%20Script%20Guide%20-%20For%20Storage%20Performance%20Testing.docx">Test-DiskSPDBlock Script Guide - For Storage Performance Testing.docx</a></strong></p>
