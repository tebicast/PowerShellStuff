function Get-MachineInfo{
    Param(
    [string[]]$ComputerName,
    [string]$LogFailuesToPath,
    [string]$Protocol = "wsman",
    [switch]$ProtocolFallback
    )
    foreach ($computer in $ComputerName){

        #Establish session protocol
        if($protocol -eq 'Dcom') {
            $option = New-CimSessionOption -Protocol Dcom
        }#End of if 
        else {
            $option = New-CimSessionOption -Protocol Wsman
        }#End of else

        #Connect session
        $session = New-CimSession -ComputerName $computer -SessionOption $option

        #Query data
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $session

        #Close session
        $session | Remove-CimSession

        #Output data
        $os | Select-Object -Property @{n='ComputerName';e={$computer}},Version,ServicePackMajorVersion

        #TODO
    }#End of foreach

}#End of function

Get-MachineInfo -ComputerName localhost