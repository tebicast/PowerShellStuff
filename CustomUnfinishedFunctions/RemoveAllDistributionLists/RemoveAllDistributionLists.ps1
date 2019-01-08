#Get-ADPrincipalGroupMembership -Identity "vrodriguez" | Where-Object {$_.GroupScope -eq "Universal"} | Select-Object SamAccountName | where-

$groups = (Get-ADPrincipalGroupMembership ksullivan | Where-Object {$_.GroupScope -eq "Universal"} | Select-Object SamAccountName | Sort-Object SamAccountName).SamAccountName
foreach ($group in $groups){
write-host "Group removed is : $group"
remove-ADPrincipalGroupMembership -Identity "ksullivan" -MemberOf $group -Confirm
}
