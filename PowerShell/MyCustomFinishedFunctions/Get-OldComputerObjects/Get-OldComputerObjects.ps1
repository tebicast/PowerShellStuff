Function Get-OldComputerObjects 
{
[CmdletBinding()]
param
(
    [Parameter(Mandatory=$True,
    ValueFromPipeline=$True, ValueFromPipelinebyPropertyName=$true)]
    [alias("Day")]
    [string]$AddDays,
    
    [Parameter(Mandatory=$True,
    ValueFromPipeline=$True, ValueFromPipelinebyPropertyName=$true)]
    [string]$DNS	
)
Begin{
        $daysAdded = [DateTime]::Today.AddDays(-$AddDays)
        $computersToFilter = Get-ADComputer -Filter {(PasswordLastSet -lt $daysAdded) -and (whenChanged -lt $daysAdded)  } -Properties *
        }
Process{
    
       TRY{
           foreach($computerDnsTest in $computersToFilter){
           $fullDnsTest = "$($computerDnsTest.name)$DNS"
           Write-Verbose "Foreach In : $fullDnsTest"
           $testDNS = Resolve-DnsName -Name $fullDnsTest -QuickTimeout -Server DC1.org -ErrorAction SilentlyContinue
           IF ($testDNS){
           Write-Warning "$($computerDnsTest.CN) IS A LIVE MACHINE!"
           
           }##IF
           ELSE{
           Write-Verbose "Creating Object for : $($computerDnsTest.CN)"
           $props = @{'ComputerName' = $computerDnsTest.CN
                      'LastLogonDate' = $computerDnsTest.LastLogonDate
                      'PasswordLastSet' = $computerDnsTest.PasswordLastSet
                      'whenChanged' = $computerDnsTest.whenChanged
                      #'lastLogonTimestamp' = $computerDnsTest.lastLogonTimestamp
                      

                        }##props
           New-Object -TypeName PSObject -Property $props
           Write-Verbose "OBJECT CREATED FOR : $($computerDnsTest.CN)"
           }##ELSE


                }##FOREACH 
            }##TRY
       CATCH{
            Write-Warning "ERROR WITH $computerDnsTest"
            }##CATCH 

        }#Process
End{}
}

Get-OldComputerObjects -AddDays 365 -DNS '.domain_membership.org' | Select-Object ComputerName,LastLogonDate,PasswordLastSet,whenChanged | Sort-Object -Property ComputerName | Export-Csv -Path  "\\fileserver\username\PossiblyOldComputerObjects.csv" 