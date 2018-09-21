FUNCTION Remove-SecDistMessageUser{
	<#
	.SYPNOSIS
	Checks if a user is in the specified security group's delivery management group and then removes the user. REQUIRES EXCHANGE MANAGEMENT SHELL!
	
	.Notes
	File Name: Remove-SecDistMessageUser.ps1
	Author: Vrodit@gmail.com , September 9/21/2018
	Requires: Exchange Management Shell for exchange cmdlets to work.
	Tips: Add Exchange PowerShell module into a standard PowerShell session SEE BELOW
	Exchange 2013 & 2016 "Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;"
	Exchange 2010 "Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010;"
	Exchange 2007 "Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin;"
	
	.DESCRIPTION
	Remove-SecDistMessageUser uses exchange's Get-DistributionGroup cmdlet to determine if that user is in the delivery management section of that security group.
	REQUIREMENTS: Powershell as admin and admin rights to exchange management shell.
	
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
	Remove-SecDistMessageUser -secGroupList (get-content "\\PATH-TO-FILE") -fullname 'FULL NAME' -LogErrors -Verbose
	
	.Link
	https://github.com/tebicast/firstrepo/tree/master/CustomFinishedFunctions/RemoveSecDistMessageUser
	
	#>
	
		[CmdletBinding()]
		PARAM (
			[Parameter(Mandatory=$true,ValueFromPipeline=$true,ValuefromPipeLineByPropertyName=$true,HelpMessage="Exchange Security Group")]
			[string[]]$secGroupList,
			
			[Parameter(Mandatory=$true,ValuefromPipeLineByPropertyName=$true)]
			[Alias('Name','UserName','User')]
			[string]$fullname,
		
			[string]$removeSecDistMessagesErrorsLog = 'c:\temp\powershell_logs\Remove-SecDistMessagesErrorsLog.txt',
	
			[string]$removeSecDistMessagesRemovedAccounts = 'c:\temp\powershell_logs\Remove-SecDistMessagesRemovedAccounts.txt',
				
			[switch]$LogErrors
		)
		BEGIN {
			
			if(-not(Test-Path -Path "C:\tem\powershell_logs\")){New-Item -ItemType "directory" -path "C:\temp\powershell_logs"}##END of if
			if (-not(Test-Path -Path "C:\temp\powershell_logs\Remove-SecDistMessagesErrorsLog.txt")){New-Item -Path "C:\temp\powershell_logs\" -ItemType "file" -Name "Remove-SecDistMessagesErrorsLog.txt"}##END of if
			if (-not(Test-Path -Path "C:\temp\powershell_logs\Remove-SecDistMessagesRemovedAccounts.txt")){New-Item -Path "C:\temp\powershell_logs\" -ItemType "file" -Name "Remove-SecDistMessagesRemovedAccounts.txt" }##END of if
			Write-Verbose "Error log will be $removeSecDistMessagesErrorsLog"
			"---------------------------------------------------------------`
			`r`nRan on: " + (Get-Date | Select-Object -Property Date) + "`r`n`r`nErrors below:" | out-file $RemoveSecDistMessagesErrorsLog -Append
			Write-Verbose "Removed Accounts will be logged to $removeSecDistMessagesRemovedAccounts"
			"---------------------------------------------------------------`
			`r`nRan on: " + (Get-Date | Select-Object -Property DateTime) + "`r`n`r`nRemoved Accounts below:" | out-file $removeSecDistMessagesRemovedAccounts -Append
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
	Remove-SecDistMessageUser -secGroupList (get-content "\\path to security group") -fullname 'Enter Full Name Here ex: Lui Kang' -LogErrors -Verbose 