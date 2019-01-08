$hostnamestxt = "\\PathTo\ServersHere.txt"
$computers = get-content “$hostnamestxt”  


Function Get-WMIComputerSessions {
<#
.SYNOPSIS
    Retrieves all user sessions from local or remote server/s
.DESCRIPTION
    Retrieves all user sessions from local or remote server/s
.PARAMETER computer
    Name of computer/s to run session query against.
.NOTES
    Name: Get-WmiComputerSessions
.EXAMPLE
Get-WmiComputerSessions -computer "server(s)"
 
Description
-----------
This command will query all current user sessions on specified 'server(s)'.
#>

[cmdletbinding(
    DefaultParameterSetName = 'session',
    ConfirmImpact = 'low'
)]
    Param(
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True)]
            [string[]]$computer
    )
Begin {
    #Create empty report
    $report = @()
    }
Process {
    #Iterate through collection of computers
    ForEach ($c in $computer) {
        #Get explorer.exe processes
        #If a computer has a logged on user, if explorer is up it means user is on it
        $proc = gwmi win32_process -computer $c -Filter "Name = 'explorer.exe'"
        #Go through collection of processes
        ForEach ($p in $proc) {
            $temp = "" | Select-Object Computer, Domain, User
            $temp.computer = $c
            $temp.user = ($p.GetOwner()).User
            $temp.domain = ($p.GetOwner()).Domain
            $report += $temp
          }
        }
    }
End {
    $report
    }
}

Get-WMIComputerSessions -computer localhost

##below determines what user accounts ending in "vrod" are logged on.
#Get-WMIComputerSessions -computer $computers | Where-Object {$_.User -like "-adm"}