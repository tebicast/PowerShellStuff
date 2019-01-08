FUNCTION New-ConsultantUser{
[CmdletBinding()]
PARAM (
	[Parameter(Mandatory=$true,
		ValueFromPipeline=$true,
		ValuefromPipeLineByPropertyName=$true,
		HelpMessage="The SAM account name.")]
	[string]$DisplayName,
    
	[Parameter(Mandatory=$true,
		ValuefromPipeLineByPropertyName=$true)]
    [string]$firstName,

    [Parameter(Mandatory=$true,
		ValuefromPipeLineByPropertyName=$true)]
    [string]$lastName,

    [Parameter(Mandatory=$true,
    ValuefromPipeLineByPropertyName=$true)]
    [string]$fullName,

    [Parameter(Mandatory=$true,
    ValuefromPipeLineByPropertyName=$true)]
    [string]$SamAccountName,

    [Parameter(Mandatory=$true,
    ValuefromPipeLineByPropertyName=$true)]
    [string]$UserPrincipalName,
   
    [Parameter(Mandatory=$true,
    ValuefromPipeLineByPropertyName=$true)]
    [string]$OrganizationalUnit,

    [Parameter(ValuefromPipeLineByPropertyName=$true)]
    [SecureString]$passWord ,

     [Parameter(Mandatory=$true,
    ValuefromPipeLineByPropertyName=$true)]
    [string]$emailAddress,

    [Parameter(ValuefromPipeLineByPropertyName=$true)]
    [Boolean]$changePasswordAtLogOn = $true,

    [Parameter(ValuefromPipeLineByPropertyName=$true)]
    [Boolean]$enabledAccount = $true,

    [Parameter(Mandatory=$true,
    ValuefromPipeLineByPropertyName=$true)]
    [string]$description,

	[string]$ERRORLOGVARIABLE = 'c:\temp\powershell_logs\createConsultantUserErrorLog.txt',

	[string]$CONTENTLOGVARIABLE = 'c:\temp\powershell_logs\createConsultantUserCHANGESMADE.txt',
		
	[switch]$LogErrors
)
BEGIN {
	if(-not(Test-Path -Path "C:\tem\powershell_logs\"))
		{New-Item -ItemType "directory" -path "C:\temp\powershell_logs" -ErrorAction SilentlyContinue}##END of if
	if (-not(Test-Path -Path "C:\temp\powershell_logs\createConsultantUserErrorLog.txt"))
		{New-Item -Path "C:\temp\powershell_logs\" -ItemType "file" -Name "createConsultantUserErrorLog.txt"}##END of if
	if (-not(Test-Path -Path "C:\temp\powershell_logs\createConsultantUserCHANGESMADE.txt"))
		{New-Item -Path "C:\temp\powershell_logs\" -ItemType "file" -Name "createConsultantUserCHANGESMADE.txt" }##END of if
	Write-Verbose "Error log will be $ERRORLOGVARIABLE"
		"---------------------------------------------------------------`
		`r`nRan on: " + (Get-Date | Select-Object -Property Date) + "`r`n`r`nErrors below:" | out-file $ERRORLOGVARIABLE -Append
	Write-Verbose "Created accounts will be logged to $CONTENTLOGVARIABLE"
		"---------------------------------------------------------------`
		`r`nRan on: " + (Get-Date | Select-Object -Property DateTime) + "`r`n`r`nCreated Accounts below:" | out-file $CONTENTLOGVARIABLE -Append
}##End of BEGIN
PROCESS{
	write-verbose "Beginning of PROCESS block"
			TRY{
                ##If user does not exist, it will throw an error and we will create the user in Catch portion of code. Existing users will be logged.
                Get-ADUser -Identity $DisplayName
                write-warning "$DisplayName ::Account already exists:: $_.Exception.Message"
				IF($LogErrors){
						"$DisplayName ::Account already exists:: " + ": $_.Exception.Message" | out-file $ERRORLOGVARIABLE -Append
						write-warning "Eror Logged to $ERRORLOGVARIABLE"
                    }##END of if
				}#end TRY
			CATCH{
                    ##Since account does not exist, we will now try to create the account.
                    TRY{
                        write-verbose "Trying to create account -- $DisplayName"
                        New-ADUser -Name $fullname -GivenName $firstName -Surname $lastName -SamAccountName $SamAccountName -UserPrincipalName $UserPrincipalName `
                         -DisplayName $DisplayName -Path $OrganizationalUnit -Description $description -AccountPassword $passWord -EmailAddress $emailAddress -ChangePasswordAtLogon $changePasswordAtLogOn -Enabled $enabledAccount 
                        write-verbose  "$DisplayName was succesfully created" 
                        "$DisplayName was succesfully created" | Out-File $CONTENTLOGVARIABLE -Append
                    }##END OF SECOND TRY
                    CATCH{
                            ##Catches any errors while trying to create the account
                            write-warning "$DisplayName ::Account Creation Failed:: $_.Exception.Message"
                            IF($LogErrors){
                                "$DisplayName ::Account Creation Failed:: " + ": $_.Exception.Message" | out-file $ERRORLOGVARIABLE -Append
                                write-warning "Eror Logged to $ERRORLOGVARIABLE"
                        }##END of if
                    }##END OF SECOND CATCH          
				}##End of CATCH	
															
}##END OF PROCESS
END{<#intenrionally empty#>}
}##End of function


$inputPassword = (Read-Host 'Type in the password for New User(s)' -asSecureString)
$csv = Import-Csv \\fileserver\vrodriguez\Scripts\Powershell\CreateUser-Consultants\brainjocks2USERS.txt -Header username,firstname,lastname,email
ForEach ($newUser in $csv){ 
  Remove-Variable importedSam
  $importedFirstName = $newUser.firstname
  $importedLastName = $newUser.LastName
  $importedFullname = "$importedFirstName $importedLastName"
  $importedSAM = $newUser.username
  $importedEmailAddress = $newUser.email
  Write-Verbose "Working now with $importedSAM"
  New-ConsultantUser -fullName $importedFullname -firstName $importedFirstName -lastName $importedLastName -SamAccountName $importedSAM -UserPrincipalName ($importedSAM + '@ansi.org')`
  -DisplayName $importedFullname -OrganizationalUnit "OU=Consultants,OU=Depts,DC=ANSI,DC=org" -passWord $inputPassword -description 'BrainJocks Team' -emailAddress $importedEmailAddress -LogErrors -Verbose 
} 


