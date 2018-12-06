$filename = '\garb.ps1'
$pathcheck = ((Get-Item -Path ".\").FullName) + $filename
$pathcheck
if(-not(Test-Path -Path ($pathcheck) ))
                {write-host "NO"}##END of if
            