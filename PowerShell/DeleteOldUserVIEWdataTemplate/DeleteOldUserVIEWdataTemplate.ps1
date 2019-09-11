##Scenario :: Created a new VIEW Horizon UEM environment space and old data was taking up space :: Script deletes old user profiles to allow for more space
##OldViewData folders named as Profiles$-ViewData -- Need to check for AD User Accounts  who have not logged in for more than the specified time duration
##and whose accounts are NOT enabled. Script removes "-ViewData" from folder string name and queries AD User Account name for information on that user
##If requirements are met, additional information on that folder is gathered and folder is moved to a location where the folders will be examined before deletion.
##Will also move associated _uempProfilePath folder to deletion area since accont is inactive.

##Below assures Powershell starts with a clean environment!
Get-Variable true | Out-Default; Clear-Host;
Get-Variable -Exclude PWD,*Preference | Remove-Variable -EA 0
##Below keeps track of when script ran for debugging purposes
$currentTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
$logOutput = '\profileMoveErrorLog_'+ $currentTime +'.txt'
Write-host "Log will be $logOutput"

##Below gets folder size information recursively, this way we can keep track of how much space we are saving with the folders that will be deleted
function Get-FolderSize {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)]
        [string[]]$Path,
 
        [switch]$force
    )
    BEGIN {
            If ($PSBoundParameters['Debug']) {
                $DebugPreference = 'Continue'
            }##end of if

            }##end of begin      
           
    PROCESS {Write-Debug "`tBeginning of PROCESS block  ++ Get-FolderSize"
        FOREACH ($folder in $path) {
            Write-Debug "Get-FolderSize--Checking $folder"
            IF (Test-Path -Path $folder) {
                IF($force){
                $params = @{'Path'=$folder
                            'Recurse'=$true
                            'Force'=$true
                            'File'=$true}
                            }##IF
                            ELSE{
$params = @{'Path'=$folder
'Recurse'=$true
'Force'=$true}
}##ELSE
                $measure = Get-ChildItem @params | Measure-Object -Property Length -Sum
[pscustomobject]@{'Path'=$folder
                                    'MegaBytes'=($measure.sum /1MB)}
            } ELSE {
Write-Debug "PATH does not exist for  :::  $folder"
[pscustomobject]@{'Path'=$folder
'MegaBytes'=0}
            } ##IF folder exists
        } ##FOREACH
    Write-Debug "`tGet-FolderSize  --  End of PROCESS block"
    } #PROCESS
    END {}
} #function  

##Below gets AD User Account info based on the string after removing "-ViewData"
##The AD User Account query criteria is set by LastLogonDate (default 6 months) and NOT enabled
##Script will also move folders whose coresponding AD User Account does not exist but still have folders taking up space
##Creates a PSCustomObject that returns information on AD User Account
##This fuction calls on Get-FolderSize **
function Get-FolderInfo {
[CmdletBinding()]
Param(
[Parameter(Mandatory=$True)]
[string]$HomeRootPath,

[Parameter(Mandatory=$True)]
[int]$numberOfMonths
    )
    BEGIN {
           If ($PSBoundParameters['Debug']) {
                $DebugPreference = 'Continue'
            }##end of if  

    }##end of begin
           
           
    PROCESS {Write-Debug "`tBeginning of PROCESS block  ++  Get-FolderInfo"
        Write-Debug "Get-FolderInfo enumerating  :::  $HomeRootPath"
        $params = @{'Path'=$HomeRootPath
                    'exclude' = '_DELETE',"_LOGS" ##This is the folder that purgible items will go to
                    'Directory'=$True}
        ForEach ($folder in (Get-ChildItem @params))  {        
            Write-Debug "Get-FolderInfo checking  :::  $($folder.name)"      
            ##BELOW REMOVES "-ViewData" to allow proper AD name
            $params = @{'Identity'=($folder.name) -replace '-ViewData',''
                        'Properties'='*'
                        'ErrorAction'='SilentlyContinue'}          
            TRY{$user = Get-ADUser @params
            Write-Debug "Get-FolderInfo  :::  $($params.Identity) AD User exists."
                if(($user.Enabled -like 'False') -and ($user.LastLogonDate -lt (get-date).AddMonths($numberOfMonths)) )
{
[pscustomobject]@{'User'=$params.Identity
'UserExist'='Exist'
'LastLogonDate'=$user.LastLogonDate
'PasswordLastSet'=$user.PasswordLastSet
'Passwordexpired'=$user.Passwordexpired
'Enabled?'=$user.Enabled
'Path'=$folder.fullname
}##pscumstomobject
}##IF
                }##TRY
            CATCH{
            Write-Debug "Get-FolderInfo  :::  $($params.Identity) AD User does not exist."
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
} ##FOREACH
    Write-Debug "`tGet-FolderInfo  --  End of PROCESS block`r`n`r`n"
    } ##PROCESS
    END {}
}

##Below sets the location of Log Files, NewUEM and Old VIEW User data. Set with defaults but allows for input changes
##Valid movable AD User Names found will allow for the creation of a new folder, _CanDelete will be appended to Profiles$ ex: \\exampleLocationPathDemo\_Delete\samaccountname_CanDelete
##OldViewData will be moved and if corresponding _uempProfilePath exists, that will be moved too
##Returns a PSCustomObject with AD User Account data and folder information
FUNCTION MoveToProfileDeleteFolder{
[CmdletBinding()]
PARAM (
[Parameter(Mandatory=$true,
ValueFromPipeline=$true,
ValuefromPipeLineByPropertyName=$true,
HelpMessage="profile that will be moved")]
   [object[]]$profileToMovePath,

[Parameter(Mandatory=$True,
        HelpMessage="Directory of the root where profiles will be placed for deletion")]
        [string]$deleteRootPath,

        [Parameter(Mandatory=$True,
        HelpMessage="Directory of the root where UEM Production Profiles are located")]
        [string]$uempProfileRootPath,

        [Parameter(Mandatory=$True,
        HelpMessage="Directory of the path where LOGS will be written located")]
        [string]$logsPath
)
BEGIN {If ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }
        Write-Debug "Begin in MoveToProfileDeleteFolder Function"
       
$_profilePath = $profileToMovePath.path
        $_userProfile = $profileToMovePath.user
$_deletePath = $deleteRootPath + "\" + $_userProfile + "_CanDelete"
        $_uempProfilePath = $uempProfileRootPath + $_userProfile
$_userProfileExist = $profileToMovePath.UserExist

        $obj = [PSCustomObject]@{'userProfile' = $_userProfile
'adStatus' = $_userProfileExist
'profileFolderSize(MB)' = (Get-FolderSize -Path $_profilePath -force).MegaBytes
'uempFolderSize(MB)' = (Get-FolderSize -Path $_uempProfilePath -force ).MegaBytes
}
       
       
}##End of BEGIN
PROCESS{
   Write-Debug "`tMoveToProfileDeleteFolder  ++  Beginning of PROCESS block *********** :: $_userProfile"

            ##Beginning of 1st TRY
TRY{

                if(-not(Test-Path -Path $_deletePath))##Check if \\exampleLocationPathDemo\Profiles$\_DELETE\samaccountname_CanDelete\ exists
                {
                New-Item -ItemType "directory" -path $_deletePath | Out-Null
                Write-Verbose "**Created  $_deletePath\"
                }##END of if

                Move-Item -LiteralPath $_profilePath -Destination $_deletePath -Force ##Moves folder to \\exampleLocationPathDemo\Profiles$\_DELETE\samaccountname_CanDelete\
                write-verbose "**Moved REGULAR profile  `"$_userProfile`"  to  $_deletePath\"
                   
                    ##Moving UEM Production Profiles
                    TRY{ ##Beginning of 2nd TRY

                        if(-not(Test-Path -Path $_uempProfilePath) -and ($_userProfileExist -eq 'NOT-IN-AD'))
                        {
                        write-warning "No Active Directory or UEM Production Profile directory for  :::  $_userProfile."
                        }##END of if
                        elseif(-not(Test-Path -Path $_uempProfilePath))
                        {
                        write-warning "No UEM Production Profile directory for  :::  $_userProfile."
                        }##END of elseif
                        else
                        {  
                        Move-Item -LiteralPath $_uempProfilePath -Destination $_deletePath -Force ##Moves folder to \\exampleLocationPathDemo\_uempProfilePath\_DELETE\samaccountname_CanDelete\
                        write-verbose "**Moved UEM profile  `"$_userProfile`"  to  :::  $_deletePath\"
                        }##END of else
                   
                    }##END OF 2nd TRY
                   
                    CATCH{
                    write-warning "MoveToProfileDeleteFolder error while moving  :::  $_uempProfilePath"
   write-warning "MoveToProfileDeleteFolder this is the error message :::  $_.Exception.Message`r`n`r`n"
                    }##END OF 2nd CATCH

            }#end 1st TRY
            ##Beginning of 1st CATCH
            CATCH{
write-warning "MoveToProfileDeleteFolder--Error while moving $profileToMovePath"
write-warning "MoveToProfileDeleteFolder this is the error message  :::  $_.Exception.Message"

                    }##End of 1st CATCH
##Below is output for each userProfile,adStatus,profileFoldersSize(MB),uempFolderSize(MB)
$obj


Write-Debug "`tMoveToProfileDeleteFolder  --  End of PROCESS block`r`n`r`n"
}##END OF PROCESS
END{<#intenrionally empty#>}
}##End of function

#####################################
#####BEGINNING OF GETTTING INPUT#####
#####################################
$defaultAnswers = [PSCustomObject]@{
                    logPathDefaultValue = '\\exampleLocationPathDemo\Profiles$\_LOGS'
                    homeRootPathDefaultValue = '\\exampleLocationPathDemo\Profiles$'
                    numberOfMonthsDefaultValue = '-6'
                    pathToDeleteFolderDefaultValue = '\\exampleLocationPathDemo\Profiles$\_DELETE'
                    uemProductionsProfilePathDefaultValue = '\\exampleLocationPathDemo\uempprofile$\'
                      }
$questions  = {
$prompt1 = Read-Host "PRESS ENTER to accept default value :: Profile root path [$($defaultAnswers.logPathDefaultValue)]"
$prompt2 = Read-Host "PRESS ENTER to accept default value :: Profile root path [$($defaultAnswers.homeRootPathDefaultValue)]"
$prompt3 = Read-Host "PRESS ENTER to accept default value :: *NEGATIVE NUMBER* Months since last time AD user logged on :: [$($defaultAnswers.numberOfMonthsDefaultValue)]"
$prompt4 = Read-Host "PRESS ENTER to accept default value :: Path to put files for deletion :: [$($defaultAnswers.pathToDeleteFolderDefaultValue)]"
$prompt5 = Read-Host "PRESS ENTER to accept default value :: UEM Productions profile path :: [$($defaultAnswers.uemProductionsProfilePathDefaultValue)]"

$changedAnswers = [PSCustomObject]@{
logPathDefaultValue= ($defaultAnswers.logPathDefaultValue,$prompt1)[[bool]$prompt1]
homeRootPathDefaultValue= ($defaultAnswers.homeRootPathDefaultValue,$prompt2)[[bool]$prompt2]
numberOfMonthsDefaultValue = [math]::Abs(($defaultAnswers.numberOfMonthsDefaultValue,$prompt3)[[bool]$prompt3]) * (-1)
pathToDeleteFolderDefaultValue = ($defaultAnswers.pathToDeleteFolderDefaultValue,$prompt4)[[bool]$prompt4]
uemProductionsProfilePathDefaultValue = ($defaultAnswers.uemProductionsProfilePathDefaultValue,$prompt5)[[bool]$prompt5]
}

Write-Host "Below are the values you entered"
$changedAnswers | Out-Host

##Forces user to type "y" or "Y"
$again = Read-Host "Do you accept the values entered (y) or ask you again (n)"
    if ($again -ne "y"){

        &$questions
    }
    else {
    $defaultAnswers.logPathDefaultValue =  $changedAnswers.logPathDefaultValue
    $defaultAnswers.homeRootPathDefaultValue =  $changedAnswers.homeRootPathDefaultValue
    $defaultAnswers.numberOfMonthsDefaultValue =  [math]::Abs($changedAnswers.numberOfMonthsDefaultValue)* (-1)
    $defaultAnswers.pathToDeleteFolderDefaultValue =  $changedAnswers.pathToDeleteFolderDefaultValue
    $defaultAnswers.uemProductionsProfilePathDefaultValue =  $changedAnswers.uemProductionsProfilePathDefaultValue
   
            }
}##End of $defaultAnswers
&$questions
#####################################
#####Ending of OF GETTTING INPUT#####
#####################################


TRY{
if(-not($defaultAnswers.logPathDefaultValue ,$defaultAnswers.homeRootPathDefaultValue  | test-path))
    {
        "THIS SCRIT WILL TERMINATE, PROVIDE VALID PATHS"
        return
    }##END of if
   
    }#end TRY
    CATCH{
"The root path for logging errors has failed with the message : $_.Exception.Message" | out-host
    return
}##End of CATCH


"`r`nRan on: " + ($('{0:MM/dd/yyyy} {0:HH:mm:ss}' -f (Get-Date))) + "`r`n`r`nLog below:"  | out-file $("$($defaultAnswers.logPathDefaultValue)" + "$logOutput") -Append
Write-Host "Will start script"


$profileData = Get-FolderInfo -HomeRootPath $defaultAnswers.homeRootPathDefaultValue -numberOfMonths $defaultAnswers.numberOfMonthsDefaultValue -Debug -Verbose

$individualProfileOutput = foreach ($profileObject in $profileData){moveToProfileDeleteFolder -profileToMovePath $profileObject -deleteRootPath $defaultAnswers.pathToDeleteFolderDefaultValue `
-uempProfileRootPath $defaultAnswers.uemProductionsProfilePathDefaultValue -logsPath $defaultAnswers.logPathDefaultValue -Verbose -debug  }

$allFoldersDeletedSPace = [PSCustomObject]@{
'ProfileFolderSpaceDeleted(MB)' = ($individualProfileOutput.'profileFolderSize(MB)' | Measure-Object -Sum).sum                
'uempFolderSizeFolderSpaceDeleted(MB)' = ($individualProfileOutput.'uempFolderSize(MB)' | Measure-Object -Sum).sum}
$allFoldersDeletedSPace | Add-Member -MemberType NoteProperty -name 'totalSpaceDeleted' -Value ($allFoldersDeletedSPace.'ProfileFolderSpaceDeleted(MB)' + $allFoldersDeletedSPace.'uempFolderSizeFolderSpaceDeleted(MB)')  

$allFoldersDeletedSPace |  Tee-Object -FilePath $("$($defaultAnswers.logPathDefaultValue)" + "$logOutput")  -Append | Out-Host

$individualProfileOutput |  Tee-Object -FilePath $("$($defaultAnswers.logPathDefaultValue)" + "$logOutput") -Append | Out-Host