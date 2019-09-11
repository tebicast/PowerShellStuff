
##Admin@Tebicast.com
##Tested with powershell V. 5 , need Domain Admin rights
##Tested with vCenter 6.0
## Function works with no errors FOR ME!,Recommend to add ERROR AND CHANGES VERIFICATION!!
## All variables are needed including a working SourceVMTemplate and OsCustomizationFile. Add-Script discussed below are optional.
## With a little understanding of PowerCLI and VmWare VM's requirements, this can be tailored to your needs.
##It does the following ::::::
## • Adds a DNS record + PTR record , make sure that you provide an available IP
## • Joins Domain -- You need to include this as part of your $vCenter_SourceVMTemplate
## • Ram is configurable
## • CPU cores are configurable(Number of Cores Per Socket AND Total Number of Cores)
## • Creates Disk's (overwrites what you provide in Template), Formats disk as well (via powershell at end of script)
## • Selects datastore with most space – can be set to a static one
## • Change portgroup if needed
## • Change network info : IP(static/dhcp) , DNS, subnet mask , DG….
## • After VM is created, can run powershell commands – currently has scripts that enable RDP

##Both tests below ran in under 9 minutes and no errors (My Environement Hardware will vary from yours**)
##Test 1
##8GB RAM, 4 CPU: 2 Virtual Socket, 65 GB Thick Provision Eager Zeroed, static IP + network info , in domain, given computer name, after instalsl powershell scripts

##Test 2
##32GB RAM, 32 CPU: 16 Virtual Socket, 3 Thick Provision Eager Zeroed Hard drives 70 GB, 75 GB and 80 GB , static IP + network info , in domain, given computer name, after installs powershell scripts

##Make sure you have PowerCLI modules!
#Install-PackageProvider -Name NuGet -confirm:$false -Force
#Install-Module -Name vmware.powercli -Scope AllUsers –AllowClobber -confirm:$false -Force
#Set-PowerCLIConfiguration -ParticipateInCeip $false -Scope AllUsers -Confirm:$false
#Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Scope AllUsers -Confirm:$false
#Get-Module -ListAvailable VMware* | Import-Module -Verbose

###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################



##Below assures Powershell starts with a clean environment!
Get-Variable true | Out-Default; Clear-Host;
Get-Variable -Exclude PWD,*Preference | Remove-Variable -EA 0
###########################################################################################################################################
###FUNCTIONS BEGIN HERE $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
Function CheckOSCustomizationStarted([string] $VM)
{
    Write-Host "Verifying that Customization for VM $VM has started"
    $i=60 #time-out of 5 min
while($i -gt 0)
{
$vmEvents = Get-VIEvent -Entity $VM
$startedEvent = $vmEvents | Where-Object { $_.GetType().Name -eq "CustomizationStartedEvent" }
if ($startedEvent)
{
            Write-Host  "Customization for VM $VM has started"
return $true
}
else
{
Start-Sleep -Seconds 5
            $i--
}
}
    Write-Warning "Customization for VM $VM has failed"
    return $false
}

Function CheckOSCustomizationFinished([string] $VM)
{
    Write-Host  "Verifying that Customization for VM $VM has finished"
    $i = 60 #time-out of 5 min
while($true)
{
$vmEvents = Get-VIEvent -Entity $VM
$SucceededEvent = $vmEvents | Where-Object { $_.GetType().Name -eq "CustomizationSucceeded" }
        $FailureEvent = $vmEvents | Where-Object { $_.GetType().Name -eq "CustomizationFailed" }
if ($FailureEvent -or ($i -eq 0))
{
Write-Warning  "Customization of VM $VM failed"
            return $False
}
if ($SucceededEvent)
{
            Write-Host  "Customization of VM $VM Completed Successfully"
            Start-Sleep -Seconds 30
            Write-Host  "Waiting for VM $VM to complete post-customization reboot"
            Wait-Tools -VM $VM -TimeoutSeconds 300
            Start-Sleep -Seconds 30
            return $true
}
        Start-Sleep -Seconds 5
        $i--
}
}

Function Restart-VM([string] $VM)
{
    Restart-VMGuest -VM $VM -Confirm:$false | Out-Null
    Write-Host "Reboot VM $VM"
    Start-Sleep -Seconds 60
    Wait-Tools -VM $VM -TimeoutSeconds 300 | Out-Null
    Start-Sleep -Seconds 10
}

function Add-Script([string] $script,$parameters=@(),[bool] $reboot=$false){
    $i=1
    foreach ($parameter in $parameters)
    {
        if ($parameter.GetType().Name -eq "String") {$script=$script.replace("%"+[string] $i,'"'+$parameter+'"')}
        else                                        {$script=$script.replace("%"+[string] $i,[string] $parameter)}
        $i++
    }
    $script:scripts += ,@($script,$reboot)
}

Function Test-IP([string] $VM_IPAddress)
{
  if (-not ($VM_IPAddress) -or (([bool]($VM_IPAddress -as [IPADDRESS])))) { return $true} else {return $false}
}
###FUNCTIONS END HERE $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
###########################################################################################################################################


#******************************************************************************************************************************************
###VARIABLES ***********************************************************************************************************
#******************************************************************************************************************************************


$ActiveDirectoryDomain = "company.org"                              #AD Domain to join
$vCenter_Instance = "viCenterName"                                  #vCenter instance to connect to
$vCenter_Cluster = "vCenter_Cluster_Name"                           #vCenter cluster to deploy VM
$vCenter_SourceVMTemplate = Get-Template -Name "vCenterTemplate"    #vCenter template to deploy VM
$vCenter_SourceCustomSpectemp = "tempSpec" + (Get-Random)           #Generate a random name for the tempSpec to allow parallel runs
$vCenter_CustomizationSpec = "vCenterCustomicationVmFile"           #vCenter customization to use for VM
$vCenter_FolderVMLocation = "vmFolderLocationName"                  #Folderlocation in vCenter for VM
$vCenter_DiskStorageFormat = "EagerZeroedThick"                     #Diskformtat to use (Thin / Thick) for VM
$vCenter_VM_NetworkName = "DevelopmentExampleNetName"               #Portgroup to use for VM
#****#Number of Virtual Sockets =  $vCenter_VM_TotalNumOfCores DIVIDED BY $vCenter_VM_NumCoresPerSocket              
$vCenter_VM_NumCoresPerSocket = 2                                   ##Number of cores per socket
$vCenter_VM_TotalNumOfCores = 32                                    ##Total number of cores
$vCenter_VM_RAMMemory = 32                                          ##Memory of VM In GB
$vCenter_VM_DisksCapacity =  70,75,80                               ##Disksizes of VM in GB ...Will create a new hard disk for each item in array
$vCenter_VM_SubnetLength =  "255.255.255.0"                         ##Subnetlength IP address to use (24 means /24 or 255.255.255.0) for VM
$vCenter_VM_GateWay = "10.4.200.1"                                  ##Gateway to use for VM
$ActiveDirectoryDomainController =  'PENN_DomainC_3'                ##Domain controller
$VM_Hostname = "hostNameExample"                                    ##Hostname
$VM_IPAddress = '10.55.3.66'                                        ##IP Address to be used -- Must be a valid IP address

###CONNECT TO VCENTER
Connect-VIServer -Server $vCenter_Instance -Credential (Get-Credential -Credential "company\adminUserNameHere") -Verbose
###BELOW GETS THE DATASTORE THAT HAS THE MOST FREE SPACE -- Excludes anything starting with SQL (customize to your liking)
$DataStore = Get-Datastore -Location '3par_esx_cluster1'  |
Where-Object {$_.name -notlike '*sql*' } |
Sort-Object -Property FreeSpaceGB -Descending |
Select-Object -First 1
###BELOW ARE DNS SERVERS FOR VM
$VM_DNS =
"10.40.4.2",
"10.30.3.2",
"10.20.2.2"              

##Input Local Admin Credentials -- Local Guest VM Admin Password to run Invoke-VMScript
$VM_GUEST_AdminCreds =  Get-Credential  -UserName "$VM_Hostname\guestLocalAdministrator" -message 'This password is from your customization file!'

###Adds a Domain A Record and a PTR Record  
$ADD_DNSSERVERRESOURCERECORD_A_PARAMS = @{
Name = $VM_Hostname
ComputerName = $ActiveDirectoryDomainController
ZoneName = $ActiveDirectoryDomain
CreatePtr = $True
AllowUpdateAny = $True
IPv4Address = $VM_IPAddress
TimeToLive = '01:00:00'
Verbose = $True
}
Add-DnsServerResourceRecordA @ADD_DNSSERVERRESOURCERECORD_A_PARAMS

###Some really quick checks
If ($VM_Hostname.Length -gt 15) {write-Host -ForegroundColor Red "$VM_Hostname is an invalid hostname"; break}
If (-not (Test-IP $VM_IPAddress)) {write-Host -ForegroundColor Red "$VM_IPAddress is an invalid address"; break}

###CLONING THE CUSTOMIZATION FILE
$NEW_OSCUSTOMIZATIONSPEC_PARAMS = @{
Name = $vCenter_SourceCustomSpectemp
Type = 'NonPersistent'
    Spec = Get-OSCustomizationSpec -Name $vCenter_CustomizationSpec
}
New-OSCustomizationSpec @NEW_OSCUSTOMIZATIONSPEC_PARAMS

###SET THE OSCUSTOMIZATIONNICMAPPING FROM THE CLONED CUSTOMIZATION FILE
$SET_OSCUSTOMIZATIONNICMAPPING_PARAMS = @{
IpMode = 'UseStaticIP'
IpAddress = $VM_IPAddress
SubnetMask = $vCenter_VM_SubnetLength
DefaultGateway = $vCenter_VM_GateWay
DNS = $VM_DNS
    OSCustomizationNicMapping = Get-OSCustomizationSpec -Name $vCenter_SourceCustomSpectemp | Get-OSCustomizationNicMapping
}
Set-OSCustomizationNicMapping @SET_OSCUSTOMIZATIONNICMAPPING_PARAMS

### DEPLOY VM
Write-Host "Deploying Virtual Machine with Name: [$VM_Hostname] using Template: [$vCenter_SourceVMTemplate] and Customization Specification: [$SourceCustomSpec] on cluster: [$vCenter_Cluster]" -foregroundcolor red
$NEW_VM_PARAMS = @{
Name = $VM_Hostname
Template = $vCenter_SourceVMTemplate
ResourcePool = $vCenter_Cluster
OSCustomizationSpec = Get-OSCustomizationSpec -Name $vCenter_SourceCustomSpectemp
Location = $vCenter_FolderVMLocation
Datastore = $Datastore
DiskStorageFormat = $vCenter_DiskStorageFormat
Confirm = $False
Verbose = $True
}
New-VM @NEW_VM_PARAMS

##Adding additional hard-drives if specified in $DiskCapacity Array when declaring variable
if( $vCenter_VM_DisksCapacity.Length -gt 0 ){
    Get-HardDisk -VM $VM_Hostname | Set-HardDisk -CapacityGB $vCenter_VM_DisksCapacity[0] -Verbose -confirm:$false
    $vCenter_VM_DisksCapacity | Select-Object -skip 1| ForEach-Object { New-HardDisk -VM $VM_Hostname -CapacityGB $_ -Verbose -confirm:$false}
}

##Sets the memory to the specified amount
Set-VM -VM $VM_Hostname -MemoryGB $vCenter_VM_RAMMemory -Verbose -confirm:$false

##Sets the Portgroup
Get-Vm $Hostname | Get-NetworkAdapter | Set-NetworkAdapter -PortGroup $vCenter_VM_NetworkName  -confirm:$false 

##Changes the corespersocket and totalnumberofcores as specified  
$spec = new-object -typename VMware.VIM.virtualmachineconfigspec -property @{'numcorespersocket'=$vCenter_VM_NumCoresPerSocket;'numCPUs'=$vCenter_VM_TotalNumOfCores}  
(Get-VM $VM_Hostname -Verbose).ExtensionData.ReconfigVM_Task($spec)

###STARTING VM
Write-Host "Virtual Machine $VM_Hostname Deployed. Powering On" -foregroundcolor red
$START_VM_PARAMS = @{
VM = $VM_Hostname
Verbose = $True
}
Start-VM @START_VM_PARAMS

##CHECK THAT VM CUSTOMIZATION HAS STARTED AND FINISHED SUCCESFULLY
if (
   -not(CheckOSCustomizationStarted $VM_Hostname),
        -not(CheckOSCustomizationFinished $VM_Hostname)
)
{
Write-Host "Customization checks passed" -foregroundcolor Green
}
else
{
Write-Host "Customization has failed , please check logs" -foregroundcolor red
break
}

## THESE POWERSHELL COMMANDS RUN AFTER THE VM IS DEPLOYED
Clear-Variable scripts -ErrorAction SilentlyContinue
Add-Script 'Import-Module NetSecurity; Set-NetFirewallRule -DisplayGroup "File and Printer Sharing" -enabled True'
Add-Script 'Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -name fDenyTSConnections -Value 0;
            Enable-NetFirewallRule -DisplayGroup "Remote Desktop";
            Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -name UserAuthentication -Value 0'
#Add-Script 'New-Item -Path "c:\" -Name "ALLGOOD" -ItemType "directory"' ##Can use this to test the above ran :-)
##CALLING THE ABOVE POWERSHELL SCRIPTS
foreach ($script in $scripts)
{
    Invoke-VMScript -ScriptText $script[0] -VM $VM_Hostname -GuestCredential $VM_GUEST_AdminCreds -Verbose
    if ($script[1]) {Restart-VM $VM_Hostname}
}

###DELETES THE TEMP SPEC THAT WAS USED
$REMOVE_OSCUSTOMIZATIONSPEC_PARAMS = @{
Confirm = $False
Customizationspec = Get-OSCustomizationSpec -name $vCenter_SourceCustomSpectemp
Verbose = $True
}
Remove-OSCustomizationSpec @REMOVE_OSCUSTOMIZATIONSPEC_PARAMS

##Will until there is a PS connection to the guest vm
while (-not(Test-WSMan -ComputerName $Hostname)){Start-Sleep -Seconds 1}
##Once connetion is verified, it will format all the new raw drives!
Invoke-Command -ComputerName $Hostname -ScriptBlock {
Stop-Service -Name ShellHWDetection
$rawDisks = Get-Disk | Where-Object PartitionStyle -eq 'raw'
$rawDisks | ForEach-Object {
Initialize-Disk $_.number -PartitionStyle GPT
$driveletter = New-Partition $_.number -AssignDriveLetter -UseMaximumSize
Format-Volume -DriveLetter $driveLetter.Driveletter -FileSystem NTFS -Force -Confirm:$false
}
Start-Service -Name ShellHWDetection
Start-Sleep -Seconds 3
Restart-Computer -Force
}##end of invoke-command

### End of Script ##############################
Write-Host "$VM_Hostname finished deploying!!!!" -foregroundcolor red
################################################
####REMINDER TO CLOSE VCENTER SESSION!!!!!!!!WILL NEED TO BE OUTSIDE OF FUNCTION IF LOOPING