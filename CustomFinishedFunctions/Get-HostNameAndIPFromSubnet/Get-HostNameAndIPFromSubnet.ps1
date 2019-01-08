Function Test-ComputerConnection 
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$True,
		ValueFromPipeline=$True, ValueFromPipelinebyPropertyName=$true)]
		[alias("CN","MachineName","Device Name")]
		[string]$ComputerName	
	)
	Begin{
        [int]$timeout = 20
		[switch]$resolve = $true
		[int]$TTL = 128
		[switch]$DontFragment = $false
		[int]$buffersize = 32
		$options = new-object system.net.networkinformation.pingoptions
		$options.TTL = $TTL
		$options.DontFragment = $DontFragment
		$buffer=([system.text.encoding]::ASCII).getbytes("a"*$buffersize)}
	Process{
		$ping = new-object system.net.networkinformation.ping
		try
		{$reply = $ping.Send($ComputerName,$timeout,$buffer,$options)}
		catch
		{$ErrorMessage = $_.Exception.Message}
		if ($reply.status -eq "Success")
		{$props = @{ComputerName=$ComputerName
						Online=$True}}
		else
		{$props = @{ComputerName=$ComputerName
						Online=$False}}
		New-Object -TypeName PSObject -Property $props}
	End{}
}


function Get-HostNameAndIpFromSubnet {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True,
                    HelpMessage="Subnet Lists to enumerate")]
                    [string[]]$listofSubnets 
    )
    BEGIN {
        $Pingable = @()
        $NotPingable = @()
        $allSubnetIps = @()
            FOREACH ($ip in $listofSubnets){
                 FOR ($i=1; $i -le 254; $i++){
                    $newIP = "$ip" + ".$i"
                    $allSubnetIps += $newIP
                    #write-verbose "IP is : $newIP"
                                            }##FOR
                                            }##FOREACH  
    }##BEGIN
    PROCESS {

        foreach  ($subnetaddress in $allSubnetIps){
            $pingtest = Test-ComputerConnection -ComputerName $subnetaddress 
            Write-Verbose "Test-ComputerConnection on : $subnetaddress "
            IF($pingtest.online){
                $Pingable += $subnetaddress
                Write-Verbose "$subnetaddress IS UP!!"
                TRY{
                    ##adding -first 1 in case it resolves a dnsname with multiple pointer records
                    $result = Resolve-DnsName -Name $subnetaddress -DnsOnly -QuickTimeout -Server nj-dc-1-08.ansi.org | Select-Object namehost -First 1
                    IF ($Result){
                        Write-Verbose "$($result.NameHost)" #-replace '.ansi.org','')
                         
                         [pscustomobject]@{'Host Name'=($Result.Namehost) -replace '.ansi.org',''
                                                'IP Address'=$subnetaddress
                                                'Domain Name'='nj-dc-1-08.ansi.org'
                                                }##pscumstomobject
                         }##IF  
                }
                CATCH{
                    Write-Verbose "Cant resolve $subnetaddress!!!"
                }
            }##IF
            ELSE{
                $NotPingable += $subnetaddress
                Write-Warning "$subnetaddress IS DOWN!!"
            }
                                                    }##foreach

}##PROCESS
END{}
}##END OF FUNCTION
Get-HostNameAndIpFromSubnet -listofSubnets ( Get-Content "\\fileserver\vrodriguez\gilIPList.txt") | Export-Csv -Path "\\fileserver\vrodriguez\FINALGet-HostNameAndIPFromSubnet.csv" -Encoding ascii -NoTypeInformation


