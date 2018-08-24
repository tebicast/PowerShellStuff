Get-WmiObject Win32_Service -filter "name=BITS" | ForEach-Object -Process {$_.Change($null, $null, $null, $null, $null, $null, $null, "PassW0rd", $null, $null, $null) }
#11 parameters in total , could leave the 3 $null after "PassW0rd" if wanted
#-process parameter specifies a script block
#$null for parameters we dont want to change
