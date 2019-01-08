FUNCTION enable-CustPsRemoting {
    [CmdletBinding()]
    PARAM (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage="Computer name or IP address")]
        [Alias('hostname')]
        [string[]]$computername,
        
        [string]$WinRmFailedCustPsRemoting = 'c:\temp\powershell_Logs\WinRmFailedCustPsRemoting.txt',

        [string]$pingFailedCustPsRemoting = 'c:\temp\powershell_Logs\pingFailedCustPsRemoting.txt',

        [string]$ErrorLog = 'c:\temp\powershell_Logs\enable-CustPsRemotingErrorLog.txt',
       
        [switch]$LogErrors

    )
    BEGIN {
        Write-Verbose "Error log will be $ErrorLog"
        "---------------------------------------------------------------`
        `r`nRan on: " + (Get-Date | Select-Object -Property DateTime) + "`r`n`r`nWINRM not enabled on list below:" | out-file $WinRmFailedCustPsRemoting -Append
    }
    PROCESS{
        Write-Verbose "Beginning of PROCESS block"
        foreach($computer in $computername){##Beginning of foreach
        IF(Test-Connection -ComputerName $computer -Count 1 -ErrorAction SilentlyContinue ) {
        TRY{
            Write-Verbose "Successful ping on: $computer"
            #####CODE HERE IF COMPUTER PINGABLE
                #$cmd1 = "cmd /c 'C:\Windows\System32\PsExec.exe' \\$computer -s -i powershell.exe enable-psremoting -force"  
                #if(Invoke-Expression -Command $cmd1  ) {Write-Verbose "Enable-psremoting return code 0 on: $computer"} 
                #ELSE{
					#"$computer" | out-file $WinRmFailedCustPsRemoting -Append
					#Write-Warning "WINRM not enabled on $computer" 	
					#}##End of else

                    Invoke-Expression -Command "cmd /c 'C:\Windows\System32\PsExec.exe' \\$computer -s -i powershell.exe enable-psremoting -force" -ErrorAction SilentlyContinue -ErrorVariable testingPsExec
                    if ($testingPsExec -like "*with error code 0.*"){Write-Verbose "Enable-psremoting return code 0 on: $computer"}
                    ELSE{
					"$computer" | out-file $WinRmFailedCustPsRemoting -Append
					Write-Warning "WINRM not enabled on $computer" 	
					}##End of else

        }##END of TRY 
		CATCH{  
            Write-Warning "$computer failed : $_.Exception.Message"
            if($LogErrors){
                $computer + ": $_.Exception.Message" | Out-File $ErrorLog -Append
                Write-Warning "Logged to $ErrorLog"
                            }##End if ($LogErrors)
                    }##End of CATCH
        }##end of if (Test-Connection -ComputerName $computer -Count 1 -ErrorAction SilentlyContinue ) 
		ELSE{
			Write-Warning -WarningVariable +failedPing "Ping failed on: $computer" 
				}##End of else 
			}##End of foreach ($computer in $computername)
        "---------------------------------------------------------------`
        `r`nRan on: " + (Get-Date | Select-Object -Property DateTime) + "`r`n`r`nPing Failed on list below:" | out-file $pingFailedCustPsRemoting -Append
        "`r`nPing Failed on:" + "$failedPing" -split "Ping failed on: "| out-file $pingFailedCustPsRemoting -Append
		}##End of process
        END{<#intentionally empty#>}
}##End of Function


#$hostnametxt = "\\fileserver\vrodriguez\Scripts\Powershell\testNodeList.txt"
enable-CustPsRemoting(get-content "\\fileserver\vrodriguez\Scripts\Powershell\serversWithoutWinRmEnabled9_13_2018.txt") -LogErrors  -Verbose 

#(Get-WmiObject Win32_Process -ComputerName filesharewitnes | ?{ $_.ProcessName -match "PSEXESVC" }).Terminate()