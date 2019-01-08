#Get-ADPrincipalGroupMembership -Identity "user2" | Where-Object {$_.GroupScope -eq "Universal"} | Select-Object SamAccountName | where-

$groups = (Get-ADPrincipalGroupMembership user1 | Where-Object {$_.GroupScope -eq "Universal"} | Select-Object SamAccountName | Sort-Object SamAccountName).SamAccountName
foreach ($group in $groups){
write-host "Group removed is : $group"
remove-ADPrincipalGroupMembership -Identity "user1" -MemberOf $group -Confirm
}
