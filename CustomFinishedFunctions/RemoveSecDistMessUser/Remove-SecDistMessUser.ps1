FUNCTION Remove-SecDistMessUser{
<#
.SYPNOSIS
Checks if a user is in the specified security group's delivery management group and then removes the user. REQUIRES EXCHANGE MANAGEMENT SHELL!

.DESCRIPTION
Remove-SecDistMessUser uses exchange's Get-DistributionGroup cmdlet to determine if that user is in the delivery management section of that security group.

.PARAMETER secGroupLIst
One or more security group.

.PARAMETER fullname
The full name as it would appear in that Microsoft.Exchange.Data.Directory.ADObjectID object.

.PARAMETER removeSecDistMessagesErrorsLog
When used with -LogError, specifies the file path and name to which any error in TRY will be logged to. Defaults to 'c:\temp\powershell_Logs\Remove-SecDistMessagesErrorsLog.txt'.

.PARAMETER removeSecDistMessagesRemovedAccounts
Specifies the file path and name to which the removed accounts will be logged to. Defaults to 'c:\temp\powershell_Logs\Remove-SecDistMessagesRemovedAccounts.txt'.

.PARAMETER LogErrors
Specify this switch to create a text log file of errors in TRY.

.EXAMPLE
Remove-SecDistMessUser -secGroupList (get-content "\\PATH-TO-FILE") -fullname 'FULL NAME' -LogErrors -Verbose

.Link

#>

	[CmdletBinding()]
	PARAM (
		[Parameter(Mandatory=$true,ValueFromPipeline=$true,ValuefromPipeLineByPropertyName=$true,HelpMessage="Exchange Security Group")]
		[string[]]$secGroupList = " " ,
		
		[string]$fullname = " ",
	
		[string]$removeSecDistMessagesErrorsLog = 'c:\temp\powershell_logs\Remove-SecDistMessagesErrorsLog.txt',

        [string]$removeSecDistMessagesRemovedAccounts = 'c:\temp\powershell_logs\Remove-SecDistMessagesRemovedAccounts.txt',
        	
		[switch]$LogErrors
	)
	BEGIN {
		
		if(-not(Test-Path -Path "C:\tem\powershell_logs\")){New-Item -ItemType "directory" -path "C:\temp\powershell_logs"}
		if (-not(Test-Path -Path "C:\temp\powershell_logs\Remove-SecDistMessagesErrorsLog.txt")){New-Item -Path "C:\temp\powershell_logs\" -ItemType "file" -Name "Remove-SecDistMessagesErrorsLog.txt"}##END of if
        if (-not(Test-Path -Path "C:\temp\powershell_logs\Remove-SecDistMessagesRemovedAccounts.txt")){New-Item -Path "C:\temp\powershell_logs\" -ItemType "file" -Name "Remove-SecDistMessagesRemovedAccounts.txt" }##END of if
		Write-Verbose "Error log will be $removeSecDistMessagesErrorsLog"
        "---------------------------------------------------------------`
        `r`nRan on: " + (Get-Date | Select-Object -Property Date) + "`r`n`r`nErrors below:" | out-file $RemoveSecDistMessagesErrorsLog -Append
        Write-Verbose "Removed Accounts will be logged to $removeSecDistMessagesRemovedAccounts"
        "---------------------------------------------------------------`
        `r`nRan on: " + (Get-Date | Select-Object -Property Date) + "`r`n`r`nRemoved Accounts below:" | out-file $removeSecDistMessagesRemovedAccounts -Append
	}##End of BEGIN

	PROCESS{
		write-verbose "Beginning of PROCESS block"
						FOREACH($secgroup in $secGroupList){
							write-verbose "In for each - with $secgroup"
							TRY{
								IF((Get-DistributionGroup -Identity $secgroup ).acceptmessagesonlyfrom | Where-Object {$_.name -like $fullname} -ErrorAction SilentlyContinue){
								write-warning "$secgroup Exists! IT WILL NOW BE REMOVED!!!!"
								Set-DistributionGroup -Identity $secgroup -AcceptMessagesOnlyFrom @{Remove=$fullname}
								write-warning "REMOVED $fullname from $secgroup!!!!!"
								"$fullname removed from $secgroup" | Out-File $removeSecDistMessagesRemovedAccounts -Append
								}##end of IF
							}#end TRY
						CATCH{
						write-verbose "$secgroup failed : $_.Exception.Message"
							IF($LogErrors){
							$secgroup + ": $_.Exception.Message" | out-file $removeSecDistMessagesErrorsLog -Append
							write-warning "Logged to $removeSecDistMessagesErrorsLog"
							}##END of if
						}##End of CATCH
															}#end FOREACH
	}##END OF PROCESS
	END{<#intenrionally empty#>}
}##End of function
Remove-SecDistMessUser -secGroupList (get-content "\\fileserver\vrodriguez\firstfinalsecgrouptest.txt") -fullname 'Full Name' -LogErrors -Verbose 