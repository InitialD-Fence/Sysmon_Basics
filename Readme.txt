## Sysmon Tips
## USE NOTEPAD++ BECAUSE ITS SIMPLY THE BEST.

## Run Powershell as Admin

## Install Sysmon
sysmon.exe -accepteula -i sysmonconfig-export.xml

## Update current configuration
sysmon.exe -c sysmonconfig-export.xml

## To unistall run with administrator rights
sysmon.exe -u

## Blank config

<Sysmon schemaversion="4.21">
	<HashAlgorithms>md5,sha256</HashAlgorithms>
	<CheckRevocation/>
    
    <EventFiltering>

        ## Event filtering goes here

    </EventFiltering>
</Sysmon>


## Grab 1 sample event of each event type (Notice errors for event types that have not fired yet)
## The purpose here is to see which lines of the message you want to analyze in bulk. Line 1 is always "UTCtime".

$x = 1
while ($x -ne 23 )
{
Get-WinEvent -filterhashtable @{logname="Microsoft-Windows-Sysmon/Operational";id=$x} | fl | Select-Object -First 3 | Out-File -FilePath C:\Temp\Sysmon_example.txt -Append
$x++
}

## Simple commands to get you started. Modify x Properties[x] depending on which line of the Sysmon message you wish to analyze. Remember Line 1 is always "UTCtime"

## Event ID 22 - DNS queries. 
Get-WinEvent -filterhashtable @{logname="Microsoft-Windows-Sysmon/Operational";id=22} | Format-List | Select-Object -First 10

## See the frequency and count the DNS queries, as well as see the rare/abnormal DNS queries.
Get-WinEvent -filterhashtable @{logname="Microsoft-Windows-Sysmon/Operational";id=22} | %{$_.Properties[4].Value} | Group-Object | Select-Object count, name | Sort-Object -Property count

## See the all the executables called on and their frequency.
Get-WinEvent -filterhashtable @{logname="Microsoft-Windows-Sysmon/Operational";id=1} | %{$_.Properties[4].Value} | Group-Object | Select-Object count, name | Sort-Object -Property count

## See the all unique command line calls made, frequency also important. (Possibly high in noise, start with the shorter command line entries)
Get-WinEvent -filterhashtable @{logname="Microsoft-Windows-Sysmon/Operational";id=1} | %{$_.Properties[10].Value} | Group-Object | Select-Object count, name | Sort-Object -Property count

## See the frequency and count the IP's connected to, as well as see the rare/abnormal connections. What's outside your network you don't like? C2 present???
Get-WinEvent -filterhashtable @{logname="Microsoft-Windows-Sysmon/Operational";id=3} | %{$_.Properties[14].Value} | Group-Object | Select-Object count, name | Sort-Object -Property count

## See the frequency and count the binaries making network connections, as well as see the rare/abnormal binaries that shouldn't be making call outs.
Get-WinEvent -filterhashtable @{logname="Microsoft-Windows-Sysmon/Operational";id=3} | %{$_.Properties[14].Value} | Group-Object | Select-Object count, name | Sort-Object -Property count