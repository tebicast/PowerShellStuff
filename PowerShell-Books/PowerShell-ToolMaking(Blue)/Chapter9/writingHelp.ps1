function Get-SystemInfo {

    <#
    .SYNOPSIS
    Retrieves key blah blah
    .DESCRIPTION
    Get-SystemInfo uses WMI blah blah
    .PARAMETER Computername
    One or more computer name
    .PARAMETER LogErrors
    Specify this switch blah balh
    .PARAMETER Errorlog
    When used with -LogErrors, bla
    .EXAMPLE
    Get-Content names.txt | Get-Systeminfo
    .EXAMPLE
    Get-SystemInfo -ComputerName SERVER2,SERVER2
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage="Computer name or IP address")]
        [ValidateCount(1,10)]
        [Alias('hostname')]
        [string[]]$ComputerName,
    
        [string]$ErrorLog = 'c:\retry.txt',

        [switch]$LogErrors
        )
        BEGIN {
            Write-Verbose "Error log will be $errorlog"
        }
        PROCESS {
            Write-Verbose "Beginning PROCESS block"
            foreach ($computer in $ComputerName) {
                Write-Verbose "Querying $computer"
                $os = Get-WmiObject -class Win32_OperatingSystem -ComputerName $computer
                $comp = Get-WmiObject -class Win32_ComputerSystem -ComputerName $computer
                $bios = Get-WmiObject -class Win32_BIOS -ComputerName $computer
    
                $props = @{'ComputerName'=$computer;
                            'OSVersion'=$os.version;
                            'SPVersion'=$os.servicepackmajorversion;
                            'BIOSSerial'=$bios.serialnumber;
                            'Manufacturer'=$comp.manufacturer;
                            'Model'=$comp.model}
                Write-Verbose "WMI queries complete"
                $obj = New-Object -TypeName PSObject -Property $props
                Write-Output $obj
            }
            
        }
        END {}
    }
    help Get-SystemInfo -Full
    #-ComputerName localhost -LogErrors
    #Get-SystemInfo -ErrorLog x.txt -ComputerName localhost,localhost
    #Write-Host "-----PIPELINE MODE-----"
    #'localhost','localhost' |   Get-SystemInfo -Verbose

    #Write-Host "-----PARAM MODE-----"
    #Get-SystemInfo -ComputerName localhost,localhost -Verbose
