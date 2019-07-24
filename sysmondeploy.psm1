# Sysmondeploy is designed to make it easier to quickly deploy sysmon to anywhere in your enterprise or network, for a single host, or across a list of hosts.
# Note: This function requires WinRM to be enabled.

function sysmondeploy {

# Accept user input for switch
$userinput = Read-Host "1. Deploy to single host`r`n2. Deploy to list of hosts`r`n3. Update Sysmon Config`r`n`r`nSelect Option"


switch($userinput){

'1'{
          # Deploy to single host
          $computer = Read-Host "Enter hostname"

          # Test for WinRM
         if (Test-WSMan -ComputerName $computer -ErrorAction SilentlyContinue)
                {
          
           echo "Successful connection to $computer!"

           # Make local folder for sysmon files and copy sysmon install files to folder from share drive
           mkdir \\$computer\c$\windows\sysmon  | Out-Null
           copy-item "\\NetworkShare\sysmon\*" -Destination \\$computer\c$\windows\sysmon

           echo "Successfully copied files, now installing!"

           # Remotely call commands to install sysmon with files copied down.
           Invoke-Command -ComputerName $computer -ScriptBlock {C:\windows\sysmon\Sysmon.exe -i C:\windows\sysmon\sysmonconfig.xml -accepteula  } -ErrorAction SilentlyContinue | Out-Null

           echo "Successfully deployed Sysmon to $computer."

                }
                
          else  {

            # Error handling
            $error.clear()
             echo "Failed on: $computer, WinRM disabled, try another computer..."

                }

   }
'2'{
        # Deploy to list of hosts. 1 Hostname per line of text file.
        $path = Read-Host "Enter full path to .txt file"

        $computers = Get-Content $path

foreach ($i in $computers)
          {
          # Test for WinRM
    if (Test-WSMan -ComputerName $i -ErrorAction SilentlyContinue)
            {
          
           echo "Successful connection to $i!"
           # Make local folder for sysmon files and copy sysmon install files to folder from share drive
           mkdir \\$i\c$\windows\sysmon -ErrorAction SilentlyContinue  | Out-Null
           copy-item "\\NetworkShare\sysmon\*" -Destination \\$i\c$\windows\sysmon -ErrorAction SilentlyContinue

           echo "Successfully copied files, now installing!"

           # Remotely call commands to install sysmon with files copied down.
           Invoke-Command -ComputerName $i -ScriptBlock {C:\windows\sysmon\Sysmon.exe -i C:\windows\sysmon\sysmonconfig.xml -accepteula  } -ErrorAction SilentlyContinue | Out-Null

           echo "Successfully deployed Sysmon to $i! Next computer!"
           
            }
    else    {

          # Error handling
          $error.clear()
          echo "Failed on: $i, WinRM disabled, onto next computer..."
          
            }

         }

   }
'3'{

          # Update Sysmon config file to list of computers
          $path = Read-Host "Enter full path to .txt file"

          $computers = Get-Content $path

          # Loop through computers
foreach ($i in $computers)
          {
          # Test for WinRM
    if (Test-WSMan -ComputerName $i -ErrorAction SilentlyContinue)
          
          {
          
			echo "Successful connection to $i!"
            # Remove old sysmonconfig
		    Invoke-Command -ComputerName $i -ScriptBlock {rm C:\windows\sysmon\sysmonconfig.xml } -ErrorAction SilentlyContinue | Out-Null
            # Drop new sysmon config 
			copy-item "\\NetworkShare\sysmon\*" -Destination \\$i\c$\windows\sysmon -ErrorAction SilentlyContinue | Out-Null
            # Install new sysmon config
			Invoke-Command -ComputerName $computers -ScriptBlock {C:\windows\sysmon\Sysmon.exe -i C:\windows\sysmon\sysmonconfig.xml} -ErrorAction SilentlyContinue | Out-Null

           echo "Successfully updated Sysmon Config on $i! Next computer!"
           
          }
    else 
             {

          $error.clear()
          echo "Failed on: $i, WinRM disabled, onto next computer..."
          # Error handling

		     }
          }
   }
}
}
