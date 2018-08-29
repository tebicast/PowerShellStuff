##Creating the actual pssession
$x1cComputersSessions = New-PSSession -ComputerName Server-R1,Server-R2,Server-R3
#or
$x1c1,$x1c2,$x1c3 = New-PSSession -ComputerName Server-R1,Server-R2,Server-R3


###Getting the sessions
Get-PSSession -ComputerName Server-R1

Invoke-Command -Command (Get-WmiObject -class win32_process) -Session $x1cComputersSessions
    #Unline getwmi's -computername , Remoting works over a predefined port, good for firewall exceptions
    #Computers do their own work and and send results back
    #Remoting works in parallel

Invoke-Command -Command (Get-WmiObject -class win32_process) -Session (Get-PSSession -ComputerName Server-R1,Server-R2,Server-R3)
