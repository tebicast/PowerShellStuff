function Get-SystemInfo {
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
    Get-SystemInfo -computername localhost -LogErrors
    #-ComputerName localhost -LogErrors
    #Get-SystemInfo -ErrorLog x.txt -ComputerName localhost,localhost
    #Write-Host "-----PIPELINE MODE-----"
    #'localhost','localhost' |   Get-SystemInfo -Verbose

    #Write-Host "-----PARAM MODE-----"
    #Get-SystemInfo -ComputerName localhost,localhost -Verbose
