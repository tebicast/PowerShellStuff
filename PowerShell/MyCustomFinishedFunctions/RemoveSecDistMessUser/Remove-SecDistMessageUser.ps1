FUNCTION Remove-SecDistMessageUser{
<#
.SYPNOSIS
Checks if a user is in the specified security group's delivery management group and then removes the user. REQUIRES EXCHANGE MANAGEMENT SHELL!

.Notes
version 1.0.0
Author: admin@tebicast.com
Last Updated September 9/21/2018
I've only tested this in Powershell version 5.
File Name: Remove-SecDistMessageUser.ps1
Requires: Exchange Management Shell for exchange cmdlets to work.
Tips: Add Exchange PowerShell module into a standard PowerShell session SEE BELOW
Exchange 2013 & 2016 "Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;"
Exchange 2010 "Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010;"
Exchange 2007 "Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin;"

.DESCRIPTION
Remove-SecDistMessageUser uses exchange's Get-DistributionGroup cmdlet to determine if certain users are in the delivery management section of that security group.
REQUIREMENTS: Powershell as admin and admin rights to exchange management shell.

.PARAMETER secGroupLIst
One or more security group.

.PARAMETER fullname
The full name(s) as it would appear in that Microsoft.Exchange.Data.Directory.ADObjectID object.

.PARAMETER removeSecDistMessagesErrorsLog
When used with -LogError, specifies the file path and name to which any error in TRY will be logged to. Defaults to 'c:\temp\powershell_Logs\Remove-SecDistMessagesErrorsLog.txt'.

.PARAMETER removeSecDistMessagesRemovedAccounts
Specifies the file path and name to which the removed accounts will be logged to. Defaults to 'c:\temp\powershell_Logs\Remove-SecDistMessagesRemovedAccounts.txt'.

.PARAMETER LogErrors
Specify this switch to create a text log file of errors in TRY.

.EXAMPLE
Remove-SecDistMessageUser -secGroupList 'Security Group Name Here' -fullname 'Fred Flinstone' -LogErrors -Verbose
This example will remove the user "Fred Flinstone" the Delivery Management field of the Security Group "Security Group Name Here"

.EXAMPLE
Remove-SecDistMessageUser -secGroupList (get-content "\\PATH-TO-FILE") -fullname 'FULL NAME' -LogErrors -Verbose
This example will remove the user(s) specefied in "FULL NAME" from the Delivery Management field of the Security Group specified in the input file "\\PATH-TO-FILE"

.EXAMPLE
Remove-SecDistMessageUser -secGroupList (Get-DistributionGroup -ResultSize unlimited ) -fullname 'Lui Kang','Mike Tyson' -LogErrors -Verbose 
This example will remove the users specefied 'Lui Kang','Mike Tyson' from the Delivery Management field of all the Security Groups in AD, NOTE - be aware this might use up alot of resources.

.Link

#>
[CmdletBinding()]
PARAM (
	[Parameter(Mandatory=$true,
		ValueFromPipeline=$true,
		ValuefromPipeLineByPropertyName=$true,
		HelpMessage="Exchange Security Group")]
	[string[]]$secGroupList,
	
	[Parameter(Mandatory=$true,
		ValuefromPipeLineByPropertyName=$true)]
		[Alias('Name','UserName','User')]
	[string[]]$fullname,

	[string]$removeSecDistMessagesErrorsLog = 'c:\temp\powershell_logs\Remove-SecDistMessagesErrorsLog.txt',

	[string]$removeSecDistMessagesRemovedAccounts = 'c:\temp\powershell_logs\Remove-SecDistMessagesRemovedAccounts.txt',
		
	[switch]$LogErrors
)
BEGIN {
	
	if(-not(Test-Path -Path "C:\tem\powershell_logs\"))
		{New-Item -ItemType "directory" -path "C:\temp\powershell_logs"}##END of if
	if (-not(Test-Path -Path "C:\temp\powershell_logs\Remove-SecDistMessagesErrorsLog.txt"))
		{New-Item -Path "C:\temp\powershell_logs\" -ItemType "file" -Name "Remove-SecDistMessagesErrorsLog.txt"}##END of if
	if (-not(Test-Path -Path "C:\temp\powershell_logs\Remove-SecDistMessagesRemovedAccounts.txt"))
		{New-Item -Path "C:\temp\powershell_logs\" -ItemType "file" -Name "Remove-SecDistMessagesRemovedAccounts.txt" }##END of if
	Write-Verbose "Error log will be $removeSecDistMessagesErrorsLog"
		"---------------------------------------------------------------`
		`r`nRan on: " + (Get-Date | Select-Object -Property Date) + "`r`n`r`nErrors below:" | out-file $RemoveSecDistMessagesErrorsLog -Append
	Write-Verbose "Removed Accounts will be logged to $removeSecDistMessagesRemovedAccounts"
		"---------------------------------------------------------------`
		`r`nRan on: " + (Get-Date | Select-Object -Property DateTime) + "`r`n`r`nRemoved Accounts below:" | out-file $removeSecDistMessagesRemovedAccounts -Append
}##End of BEGIN
PROCESS{
	write-verbose "Beginning of PROCESS block"
					FOREACH($name in $fullname){#Beginning of FOREACH
						write-verbose "In FOREACH with $name"
							FOREACH($secgroup in $secGroupList){
							write-verbose "In FOREACH with $secgroup"
							TRY{
								IF((Get-DistributionGroup -Identity $secgroup).acceptmessagesonlyfrom | Where-Object {$_.name -like $name} -ErrorAction SilentlyContinue){					
									write-warning "$secgroup Exists! IT WILL NOW BE REMOVED!!!!"
									Set-DistributionGroup -Identity $secgroup -AcceptMessagesOnlyFrom @{Remove=$name}
									write-warning "REMOVED $name from $secgroup!!!!!"
									"$name removed from $secgroup" | Out-File $removeSecDistMessagesRemovedAccounts -Append
									}##end of IF(Get-DistributionGroup -Identity $secgroup )....
								}#end TRY
							CATCH{
								write-warning "$name on $secgroup failed : $_.Exception.Message"
								IF($LogErrors){
										"$name on $secgroup failed with error :" + ": $_.Exception.Message" | out-file $removeSecDistMessagesErrorsLog -Append
										write-warning "Eror Logged to $removeSecDistMessagesErrorsLog"
									}##END of if
								}##End of CATCH	
							}##END of FOREACH($secgroup in $secGroupList)	
						}##END of FOREACH($name in $fullname)										
}##END OF PROCESS
END{<#intenrionally empty#>}
}##End of function
#Remove-SecDistMessageUser -secGroupList (get-content "\\path to security group") -fullname 'Enter Full Name Here ex: Lui Kang' -LogErrors -Verbose 
Remove-SecDistMessageUser -secGroupList (Get-DistributionGroup -ResultSize unlimited ) -fullname 'Lui Kang','Mike Tyson' -LogErrors -Verbose 