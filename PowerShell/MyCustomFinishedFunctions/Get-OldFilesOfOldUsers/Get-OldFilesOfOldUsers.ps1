function Get-FolderSize {
<#
.SYPNOSIS
This counts the number of files and size of all the files in the specified path. While this function was designed as it's own function , it was inteded to be used with Get-FolderInfo

.Notes
version 1.0.0
Author: admin@tebicast.com
Last Updated September 10/01/2018
I've only tested this in Powershell version 5.
File Name: Get-OldFilesOfOldUsers.ps1

.DESCRIPTION
Get-FolderSize creates a custom object that includes the amount of files in a directory along with the sum of all those files in Megabytes.

.PARAMETER Path
Specifies the folder path(s) that we will check.

.PARAMETER force
This switch adds "recurse" and "force" to the params variable which essentially recursively checks ALL files in the specified path.


.EXAMPLE
Get-FolderSize -Path $folder.fullname -force
This example will create a custom object that has force and recurse as params for the get-childitem function. The custom object will include the amount and size of all files in path.

.EXAMPLE
Get-FolderSize -Path $folder.fullname 
This example will create a custom object that does not have force or recurse params for the get-childitem function.



.Link

#>    
[CmdletBinding()]
PARAM(
    [Parameter(Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True)]
    [string[]]$Path,

    [switch]$force 
)
BEGIN {}
PROCESS {
    FOREACH ($folder in $path) {
        Write-Verbose "Checking $folder"
        IF (Test-Path -Path $folder) {
            Write-Verbose "Path exists for `"$folder`" in Get-FolderSize"
            IF($force){
                $params = @{'Path'=$folder
                            'Recurse'=$true
                            'Force'=$true
                            'File'=$true}
                            }##IF
                            ELSE{
                                $params = @{'Path'=$folder
                                'File'=$true}
                                }##ELSE
            $measure = Get-ChildItem @params | Measure-Object -Property Length -Sum
            [pscustomobject]@{'Path'=$folder
                                'Files'=$measure.count
                                'MegaBytes'="{0:N2}" -f ($measure.sum /1MB)}
                                    } 
                                    ELSE {
                                        Write-Warning "Path does not exist for `"$folder`" in Get-FolderSize"
                                        [pscustomobject]@{'Path'=$folder
                                                            'Files'=0
                                                            'MegaBytes'=0}
                                            } ##ELSE folder exists
    } ##FOREACH
} #PROCESS
END {<#Intentionally left blank#>}
}##END of function


function Get-FolderInfo {
<#
.SYPNOSIS
Get-FolderInfo takes the string of 

.Notes
version 1.0.0
Author: Vrodit@gmail.com 
Last Updated September 10/01/2018
I've only tested this in Powershell version 5.
File Name: Get-OldFilesOfOldUsers.ps1

.DESCRIPTION
Get-FolderSize creates a custom object that includes the amount of files in a directory along with the sum of all those files in Megabytes.

.PARAMETER Path
Specifies the folder path(s) that we will check.

.PARAMETER force
This switch adds "recurse" and "force" to the params variable which essentially recursively checks ALL files in the specified path.


.EXAMPLE
Get-FolderSize -Path $folder.fullname -force
This example will create a custom object that has force and recurse as params for the get-childitem function. The custom object will include the amount and size of all files in path.

.EXAMPLE
Get-FolderSize -Path $folder.fullname 
This example will create a custom object that does not have force or recurse params for the get-childitem function.



.Link
https://github.com/tebicast/firstrepo/tree/master/CustomFinishedFunctions/?????????????????????????????????????????
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$HomeRootPath,

    [Parameter(ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True)]
    [string[]]$removeString = '',

    [Parameter(ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True,
               HelpMessage="Folders to Exclude in `$HomeRootPath")]
    [string[]]$excludeFolder ,

    [Parameter(ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True,
               HelpMessage="Number of months for LastLogonDate,default is 6")]
               [Alias('LastLogOnDate','AddMonths','Months')]
    [int]$monthsForLogOnDate = '6'


)
BEGIN {}
PROCESS {
    Write-Verbose "Enumerating the `"`$HomeRootPath`" $HomeRootPath"
    $params = @{'Path'=$HomeRootPath
                'Directory'=$True}
    FOREACH ($folder in (Get-ChildItem @params)) { 
        IF($excludeFolder -notcontains  $folder.name){ 
        #IF($excludeFolder -contains  $folder.name){ 
        Write-Verbose "Checking folder $($folder.name) using Get-ChildItem in Get-FolderInfo"
        ##BELOW REMOVES ".V2" to allow proper AD name --- delete in final code
        #$params = @{'Identity'=($folder.name) -replace '.V2','' --- delete in final code
        $params = @{'Identity'=($folder.name) -replace "$removeString",''
                    'Properties'='*'
                    'ErrorAction'='SilentlyContinue'}  
        TRY{$user = Get-ADUser @params
        Write-Verbose "Ran Get-ADUser on $($params.Identity), AD account exists."
            IF(($user.Enabled -like 'False') -and ($user.LastLogonDate -lt (get-date).AddMonths(-($monthsForLogOnDate))) ){
            #The Get-FolderSize function must exist in the current session
            $result = Get-FolderSize -Path $folder.fullname -force
            [pscustomobject]@{'User'=$params.Identity
                                'UserToPipe'= $params.Identity
                                'PathToPipe'=$folder.fullname
                                'UserExist'='Exist'
                                'LastLogonDate'=$user.LastLogonDate
                                'PasswordLastSet'=$user.PasswordLastSet
                                'Passwordexpired'=$user.Passwordexpired
                                'Enabled?'=$user.Enabled
                                'Files'=$result.files
                                'MB'=$result.MegaBytes
                                'Path'=$folder.fullname
							}##pscumstomobject
                        }##if($user.Enabled -like 'False' )
		}##TRY
        CATCH{
        Write-Warning "CATCH!! $($params.Identity) AD account does not exist, in Get-FolderInfo for Get-ADUser"
            [pscustomobject]@{'User'=$params.Identity
                                'UserExist'='NOT-IN-AD'
                                'LastLogonDate'='Orphan'
                                'PasswordLastSet'='Orphan'
                                'Passwordexpired'='Orphan'
                                'Enabled?'='Orphan'
                                'Files'=0
                                'MB'=0
                                'Path'=$folder.fullname
                                }##pscumstomobject
			}##CATCH   
        }##IF ($folder.name -contains "$excludeFolder"){ 
        else{
        Write-Warning "Skipping $($folder.name) because part of `$excludeFolder!!!!"
        }
    } ##FOREACH

} ##PROCESS
END {}
}
#Get-FolderInfo -HomeRootPath '\\userpersona-mgmt\e$\Profiles$' -Verbose  |  Measure-Object -Property MB -sum
#Get-FolderInfo -HomeRootPath '\\userpersona-mgmt\e$\Profiles$' -removeString '.V2' -monthsForLogOnDate 5 -excludeFolder '_DELETE','userone.v2','usertwenty.v2' -Verbose  | Format-Table -AutoSize
(Get-FolderInfo -HomeRootPath '\\userpersona-mgmt\e$\Profiles$' -removeString '.V2' -monthsForLogOnDate 5 -excludeFolder '_DELETE','userone.v2','usertwenty.v2').pathToPipe
#Get-FolderInfo -HomeRootPath '\\userpersona-mgmt\e$\Profiles$' -removeString '.V2' -monthsForLogOnDate 1 -excludeFolder 'usertwenty.v2' -Verbose  | Format-Table -AutoSize