
<#
$RS = Get-Content "\\PathTo\ServersHere.txt"

foreach ($s in $RS){
$cmd1 = "cmd /c C:\Windows\System32\PsExec.exe \\$s -s winrm.cmd quickconfig -q"
$cmd2 = "cmd /c C:\Windows\System32\PsExec.exe \\$s -s powershell.exe enable-psremoting -force"
Invoke-Expression -Command $cmd1
Invoke-Expression -Command $cmd2
}#>


#below script is working

#$computerList = Get-Content "\\PathTo\ServersHere.txt"
#foreach ($ishost in $computerList){
Invoke-Command -computername Xlnxaport8 -command {enable-psremoting -force -Verbose}
#$cmd1 = "cmd /c '\\PathTo\ServersHere.txt' \\$ishost -s powershell.exe enable-psremoting -force"
#Invoke-Expression -Command $cmd1
#} 
