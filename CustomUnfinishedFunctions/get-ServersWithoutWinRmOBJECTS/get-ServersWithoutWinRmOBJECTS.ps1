FUNCTION Get-ServersWithoutWinRm{
<#
.SYPNOSIS
Gets one or more Servers that do not have WinRm running.

.DESCRIPTION
Get-ServersWithoutWinRm uses Test-WSMan to determine what computers have the service WinRm Running.

.PARAMETER ComputerName
One or more computer names or IP addresses

.PARAMETER ServersWithoutWinRmEnabled
Specifies the file path and name to which both non-pingable and computers without WinRM will be written to.

.PARAMETER ErrorLog
When used with -LogError, specifies the file path and name to which failed WinRm will be written. Defaults to 'c:\temp\powershell_Logs\get-serverWithoutWinRmErrorLog.txt'.

.PARAMETER LogErrors
Specify this switch to create a text log file of computers that do not have WinRm enabled

.EXAMPLE
 Get-Content names.txt | Get-ServersWithoutWinrm

.EXAMPLE
Get-ServersWithoutWinrm -ComputerName SERVER1,SERVER2 -LogErrors
#>
    [CmdletBinding()]
    PARAM (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Computer name or IP address")]
        [Alias('hostname','CN','MachineName','Name')]
        [string[]]$computername = 'localhost',

        [string]$ServersWithoutWinRmEnabled = 'c:\temp\powershell_Logs\serversWithoutWinRmEnabled.txt',

        [string]$ErrorLog = 'c:\temp\powershell_Logs\get-serverWithoutWinRmErrorLog.txt',
       
        [switch]$LogErrors

    )
    BEGIN {
        Write-Verbose "Error log will be $ErrorLog"
        "---------------------------------------------------------------`
        `r`nRan on: " + (Get-Date | Select-Object -Property Date) + "`r`n`r`nWINRM not enabled on list below:" | out-file $serversWithoutWinRmEnabled -Append
    }
    PROCESS{
        Write-Verbose "Beginning of PROCESS block"
        FOREACH($computer in $computername){
		IF(Test-Connection -ComputerName $computer -Count 1 -ErrorAction SilentlyContinue ) {
        TRY{
            Write-Verbose "Successful ping on: $computer"
            #####CODE STARTS HERE IF COMPUTER PINGABLE
                Write-Verbose "Before Test-WSMan on: $computer"
                IF(Test-WSMan -ComputerName $computer -ErrorAction SilentlyContinue){
                                Write-Verbose "WINRM enabled on: $computer"
                                }##END of if (Test-WSMan -ComputerName $computer -ErrorAction SilentlyContinue)
								ELSE{
									"$computer" | out-file $serversWithoutWinRmEnabled -Append
									Write-Warning "WINRM not enabled on $computer" 	
									}##End of else
			}##End of TRY
		    CATCH{
                Write-Warning "$computer failed : $_.Exception.Message"
                IF($LogErrors){
                $computer + ": $_.Exception.Message" | Out-File $ErrorLog -Append
                Write-Warning "Logged to $ErrorLog"
                              }##End if ($LogErrors)
                        }##End of CATCH		
		}##end of if (Test-Connection -ComputerName $computer -Count 1 -ErrorAction SilentlyContinue ) 
		ELSE{
			Write-Warning -WarningVariable +failedPing "Ping failed on: $computer" 
				}##End of else 
			}##End of foreach ($computer in $computername)
        "`r`nPing Failed on:" + "$failedPing" -split "Ping failed on: "| out-file $serversWithoutWinRmEnabled -Append
		}##End of process
    END{<#intentionally empty#>}

}##End of Function

#get-ServersWithoutWinRm(get-content "\\fileserver\vrodriguez\Scripts\Powershell\testNodeList.txt") -LogErrors -verbose

get-ServersWithoutWinRm(get-content "\\fileserver\vrodriguez\Scripts\Powershell\MOSTFULLnodelist9_13_2018.txt") -LogErrors -verbose