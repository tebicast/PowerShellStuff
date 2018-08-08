function Get-SystemInfo {
[CmdletBinding()]
param (
    [string[]]$ComputerName,

    [string]$ErrorLog
    )
    BEGIN {
        #Write-Output "Log name is $errorlog"
    }
    PROCESS {
        foreach ($computer in $ComputerName) {
            $os = Get-WmiObject -class Win32_OperatingSystem -ComputerName $computer
            $comp = Get-WmiObject -class Win32_ComputerSystem -ComputerName $computer
            $bios = Get-WmiObject -class Win32_BIOS -ComputerName $computer

            $props = @{'ComputerName'=$computer;
                        'OSVersion'=$os.version;
                        'SPVersion'=$os.servicepackmajorversion;
                        'BIOSSerial'=$bios.serialnumber;
                        'Manufacturer'=$comp.manufacturer;
                        'Model'=$comp.model}
            $obj = New-Object -TypeName PSObject -Property $props
            Write-Output $obj
        }
        
    }
    END {}
}
Get-SystemInfo -ErrorLog x.txt -ComputerName localhost,localhost