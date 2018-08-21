Get-WmiObject -class win32_bios -ComputerName localhost,localhost |
Format-Table    @{label='ComputerName';expression={$_.__Server}},
                @{label='BIOSSerial';expression={$_.SerialNumber}},
                @{label='OSBuild';expression={Get-WmiObject -class win32_operatingsystem -ComputerName $_.__Server | Select-Object -expand BuildNumber}} -AutoSize