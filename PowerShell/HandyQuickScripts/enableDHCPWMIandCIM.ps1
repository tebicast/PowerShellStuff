##Enable DHCP with WMI, using  Invoke-WmiMethod
Get-WmiObject win32_networkadapterconfiguration -filter "description like '%ThinkPad%'" |  Invoke-WmiMethod -name EnableDCHP

#Invoke-WmiMethod can only accept one type of WMI object at a time
#enable dhcp return values https://docs.microsoft.com/en-us/windows/desktop/cimwin32prov/enabledhcp-method-in-class-win32-networkadapterconfiguration

##Enable DHCP with CIM, using  Invoke-CimMethod
Get-CimInstance -ClassName win32_networkadapterconfiguration -filter "description like '%ThinkPad%'" |  Invoke-CimMethod -MethodName EnableDCHP