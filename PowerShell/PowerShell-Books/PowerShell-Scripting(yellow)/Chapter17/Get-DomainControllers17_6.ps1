foreach ($domain in (Get-ADForest).domains) { 
    Get-ADDomainController -filter * -server $domain | 
    sort hostname  |
    foreach { 
      Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $psitem.Hostname |
      select @{name="DomainController";Expression={$_.PSComputerName}}, Manufacturer, Model,@{Name="TotalPhysicalMemory(GB)";Expression={ "{0:N0}" -f  ($_.TotalPhysicalMemory / 1Gb) }}
      }
  }
  