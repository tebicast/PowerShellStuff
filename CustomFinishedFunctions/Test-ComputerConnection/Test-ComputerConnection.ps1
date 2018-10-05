Function Test-ComputerConnection 
{
    ##TAKEN FROM https://www.reddit.com/r/PowerShell/comments/3rnrj9/faster_testconnection/
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