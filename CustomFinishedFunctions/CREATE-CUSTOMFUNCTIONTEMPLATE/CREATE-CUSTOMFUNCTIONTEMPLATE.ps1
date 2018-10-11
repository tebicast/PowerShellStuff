FUNCTION CREATE-CUSTOMFUNCTIONTEMPLATE{
<#
.SYPNOSIS
My own custom template -- derived from link below
https://github.com/tebicast/PowerShellStuff/blob/master/CustomFinishedFunctions/CREATE-CUSTOMFUNCTIONTEMPLATE/CREATE-CUSTOMFUNCTIONTEMPLATE.ps1

.Notes
version 1.0.0
Author: Vrodit@gmail.com 
Last Updated  ##DATE
I've only tested this in Powershell version 5.
File Name: NAMEOFFILE.ps1
Requires: REQUIREMENTS

.DESCRIPTION
CREATE-CUSTOMFUNCTIONTEMPLATE uses ....
REQUIREMENTS: Powershell as admin .....

.PARAMETER FIRSTPARAMETER
Explain what FIRSTPARAMETER is.

.PARAMETER SECONDPARAMETER
Explain what SECONDPARAMETER is.

.EXAMPLE
CREATE-CUSTOMFUNCTIONTEMPLATE -FIRSTPARAMETER 'FIRSTPARAMETER Here' -SECONDPARAMETER 'SECONDPARAMETER Here' -LogErrors -Verbose
This example will remove the user "Fred Flinstone" the Delivery Management field of the Security Group "Security Group Name Here"

.EXAMPLE
CREATE-CUSTOMFUNCTIONTEMPLATE -FIRSTPARAMETER (get-content "\\PATH-TO-FILE") -SECONDPARAMETER 'FULL NAME' -LogErrors -Verbose
EXPLAIN ABOVE

.EXAMPLE
CREATE-CUSTOMFUNCTIONTEMPLATE -FIRSTPARAMETER (Get-CONTENT From Somewhere ) -SECONDPARAMETER 'Lui Kang','Mike Tyson' -LogErrors -Verbose 
EXPLAIN ABOVE

.Link
https://github.com/tebicast/....
#>
[CmdletBinding()]
PARAM (
	[Parameter(Mandatory=$true,
		ValueFromPipeline=$true,
		ValuefromPipeLineByPropertyName=$true,
		HelpMessage="Exchange Security Group")]
	[string[]]$FIRSTPARAMETER,
	
	[Parameter(Mandatory=$true,
		ValuefromPipeLineByPropertyName=$true)]
		[Alias('Name','UserName','User')]
	[string[]]$SECONDPARAMETER,

	[string]$ERRORLOGVARIABLE = 'c:\temp\powershell_logs\CREATEERRORLOGFILE.txt',

	[string]$CONTENTLOGVARIABLE = 'c:\temp\powershell_logs\CREATELOGFORCONTENTNOTERRORS.txt',
		
	[switch]$LogErrors
)
BEGIN {
	
	if(-not(Test-Path -Path "C:\tem\powershell_logs\"))
		{New-Item -ItemType "directory" -path "C:\temp\powershell_logs"}##END of if
	if (-not(Test-Path -Path "C:\temp\powershell_logs\CREATEERRORLOGFILE.txt"))
		{New-Item -Path "C:\temp\powershell_logs\" -ItemType "file" -Name "CREATEERRORLOGFILE.txt"}##END of if
	if (-not(Test-Path -Path "C:\temp\powershell_logs\CREATELOGFORCONTENTNOTERRORS.txt"))
		{New-Item -Path "C:\temp\powershell_logs\" -ItemType "file" -Name "CREATELOGFORCONTENTNOTERRORS.txt" }##END of if
	Write-Verbose "Error log will be $ERRORLOGVARIABLE"
		"---------------------------------------------------------------`
		`r`nRan on: " + (Get-Date | Select-Object -Property Date) + "`r`n`r`nErrors below:" | out-file $ERRORLOGVARIABLE -Append
	Write-Verbose "Removed Accounts will be logged to $CONTENTLOGVARIABLE"
		"---------------------------------------------------------------`
		`r`nRan on: " + (Get-Date | Select-Object -Property DateTime) + "`r`n`r`nRemoved Accounts below:" | out-file $CONTENTLOGVARIABLE -Append
}##End of BEGIN
PROCESS{
	write-verbose "Beginning of PROCESS block"
			##USUALLY ADD VARIABLES HERE	
			TRY{
				##TRY TO DO SOMETHING
				
				"$name removed from $secgroup" | Out-File $CONTENTLOGVARIABLE -Append
				
				}#end TRY
			CATCH{
				write-warning "LOG ERROR HERE AS WARNING : $_.Exception.Message"
				IF($LogErrors){
						"OUTPUT THE ERROR HERE :" + ": $_.Exception.Message" | out-file $ERRORLOGVARIABLE -Append
						write-warning "Eror Logged to $ERRORLOGVARIABLE"
					}##END of if
				}##End of CATCH	
			
												
}##END OF PROCESS
END{<#intenrionally empty#>}
}##End of function
#CREATE-CUSTOMFUNCTIONTEMPLATE -FIRSTPARAMETER (get-content "\\path to security group") -SECONDPARAMETER 'Enter Full Name Here ex: Lui Kang' -LogErrors -Verbose 
CREATE-CUSTOMFUNCTIONTEMPLATE -FIRSTPARAMETER (Get-CONTENT From Somewhere ) -SECONDPARAMETER 'Lui Kang','Mike Tyson' -LogErrors -Verbose 