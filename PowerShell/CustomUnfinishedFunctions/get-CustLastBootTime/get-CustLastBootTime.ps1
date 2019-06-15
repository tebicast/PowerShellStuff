$hostnamestxt = "\\PathTo\ServersHere.txt"
$computers = get-content “$hostnamestxt”  

$report = @() 
$object = @() 

foreach($computer in $computers){##beginning of foreach
    
    ping -n 1 $computer >$null
    if($lastexitcode -eq 0) {##Beginning of if
    try 
    { 
    #$object = gwmi win32_operatingsystem -ComputerName $computer  | select-object csname, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}} 
    #$object = Get-HotFix -ComputerName $computer |Sort-Object -Property  InstalledOn -Descending |   Select-Object -ExpandProperty HotFixId  -First 5
    $object = gwmi win32_operatingsystem -ComputerName $computer  | Format-Table @{LABEL='ComputerName';EXPRESSION={$_.csname}}, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}} , @{LABEL='Latest5Patches';EXPRESSION={Get-HotFix -ComputerName $computer |Sort-Object -Property  InstalledOn -Descending |   Select-Object -ExpandProperty HotFixId  -First 3 }}  
    $report += $object
    
    }
    catch [System.UnauthorizedAccessException]
    {
    Write-Host "$computer having UnauthorizedAccessException error."
    }
	 
	}##End of if
	else{Write-Host "$computer is not reachable"}
	}##End for each
$report | Sort-Object -Property lastbootuptime -Descending   