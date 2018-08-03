function Get-OsInfo {
    Param (
    [string] $computerName = 'localhost'
    )

    Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computerName
    }

Function Get-ServiceStartMode {

    Param(
    [string]$Computername='localhost',
    [string]$StartMode='Auto',
    [string]$State='Running'
    )
    
    $filter="Startmode='$Startmode' AND state='$State'"
    
    Get-CimInstance -ClassName Win32_Service -ComputerName $Computername -Filter $filter
    
    }
    
#Get-ServiceStartMode -Computername puppetdev
Function Get-DiskInfo {

    Param (
    [string]$computername='localhost',
    [int]$MinimumFreePercent=10
    )
    
        $disks=Get-WmiObject -Class Win32_Logicaldisk -Filter "Drivetype=3"
        
        foreach ($disk in $disks) {
            $perFree=($disk.FreeSpace/$disk.Size)*100
            if ($perFree -ge $MinimumFreePercent) {
                $OK=$True
            }
            else {
                $OK=$False
            }
            
            $disk | Select-Object DeviceID,VolumeName,Size,FreeSpace,@{Name="OK";Expression={$OK}}
            
        } #close foreach
    
    } #close function
    
#Get-DiskInfo -computername puppetdev