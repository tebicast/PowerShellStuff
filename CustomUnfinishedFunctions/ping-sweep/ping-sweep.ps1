$hostnamestxt = "\\PathTo\ServersHere.txt"
$computers = get-content “$hostnamestxt”  

foreach($computer in $computers){##beginning of foreach
    
    ping -n 1 $computer >$null
    if($lastexitcode -eq 0) {##Beginning of if
	
	}##End of if
	else{Write-Host "$computer is not reachable"}
	}##End for each