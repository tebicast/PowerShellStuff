##https://powershellexplained.com/2018-01-12-Powershell-switch-statement/
##ALL GATHERED FROM LINK ABOVE!


<#
You can use the $PSItem or $_ to reference the current item that was processed. 
When we do a simple match, $PSItem will be the value that we are matching. 
I will be performing some advanced matches in the next section where this will be used.
#>
#######################################################################
$a = 1, 2, 3, 4

switch($a) {
    1 { [void]$switch.MoveNext(); $switch.Current }
    3 { [void]$switch.MoveNext(); $switch.Current }
}

This will give you the results of:

    2
    4
#######################################################################
$day = 3

$lookup = @{
    0 = 'Sunday'
    1 = 'Monday'
    2 = 'Tuesday'
    3 = 'Wednesday'
    4 = 'Thursday'
    5 = 'Friday'
    6 = 'Saturday'
}

$lookup[$day]

# Output
Wednesday
#######################################################################
$day = 3

enum DayOfTheWeek {
    Sunday
    Monday
    Tuesday
    Wednesday
    Thursday
    Friday
    Saturday
}

[DayOfTheWeek]$day

# Output
Wednesday
#######################################################################
$day = 3

    if ( $day -eq 0 ) { $result = 'Sunday'        }
    elseif ( $day -eq 1 ) { $result = 'Monday'    }
    elseif ( $day -eq 2 ) { $result = 'Tuesday'   }
    elseif ( $day -eq 3 ) { $result = 'Wednesday' }
    elseif ( $day -eq 4 ) { $result = 'Thursday'  }
    elseif ( $day -eq 5 ) { $result = 'Friday'    }
    elseif ( $day -eq 6 ) { $result = 'Saturday'  }

    $result

    # Output
    Wednesday
#######################################################################
$day = 3

switch ( $day )
{
    0 { $result = 'Sunday'    }
    1 { $result = 'Monday'    }
    2 { $result = 'Tuesday'   }
    3 { $result = 'Wednesday' }
    4 { $result = 'Thursday'  }
    5 { $result = 'Friday'    }
    6 { $result = 'Saturday'  }
}

$result

# Output
'Wednesday'
#######################################################################
$result = switch ( $day )
    {
        0 { 'Sunday'    }
        1 { 'Monday'    }
        2 { 'Tuesday'   }
        3 { 'Wednesday' }
        4 { 'Thursday'  }
        5 { 'Friday'    }
        6 { 'Saturday'  }
    }
#######################################################################
$result = switch ( $day )
    {
        0 { 'Sunday' }
        # ...
        6 { 'Saturday' }
        default { 'Unknown' }
    }
#######################################################################
$item = 'Role'

switch ( $item )
{
    Component
    {
        'is a component'
    }
    Role
    {
        'is a role'
    }
    Location
    {
        'is a location'
    }
}

# Output
is a role
#######################################################################
$roles = @('WEB','Database')

switch ( $roles ) {
    'Database'   { 'Configure SQL' }
    'WEB'        { 'Configure IIS' }
    'FileServer' { 'Configure Share' }
}

# Output
Configure IIS
Configure SQL
#######################################################################
$Message = 'Warning, out of disk space'

    switch -Wildcard ( $message )
    {
        'Error*'
        {
            Write-Error -Message $Message
        }
        'Warning*'
        {
            Write-Warning -Message $Message
        }
        default
        {
            Write-Information $message
        }
    }

    # Output 
    WARNING: Warning, out of disk space
#######################################################################
switch -Regex ( $message )
    {
        '^Error'
        {
            Write-Error -Message $Message
        }
        '^Warning'
        {
            Write-Warning -Message $Message
        }
        default
        {
            Write-Information $message
        }
    }
#######################################################################
switch -Wildcard -File $path
    {
        'Error*'
        {
            Write-Error -Message $PSItem
        }
        'Warning*'
        {
            Write-Warning -Message $PSItem
        }
        default
        {
            Write-Output $PSItem
        }
    }
#######################################################################
<#
-CaseSensitiveThe matches are not case sensitive by default. 
If you need to be case sensitive then you can use -CaseSensitive.
This can be used in combination with the other switch parameters.
#>
switch ( 'Word' )
{
    'word' { 'lower case word match' }
    'Word' { 'mixed case word match' }
    'WORD' { 'upper case word match' }
}

# Output
lower case word match
mixed case word match
upper case word match
#######################################################################
<#
Normally, this is where I would introduce the break statement, but it is better that we learn how to use continue first. 
Just like with a foreach loop, continue will continue onto the next item in the collection or exit the switch if there are no more items. 
We can rewrite that last example with continue statements so that only one statement executes.
#>
switch ( 'Word' )
{
    'word' 
    {
        'lower case word match'
        continue
    }
    'Word' 
    {
        'mixed case word match'
        continue
    }
    'WORD' 
    {
        'upper case word match'
        continue
    }
}

# Output
lower case word match
#######################################################################
<#
Because a line in the input file could contain both the word Error and Warning, 
we only want the first one to execute and then continue processing the file.
#>
switch -Wildcard -File $path
{
    '*Error*'
    {
        Write-Error -Message $PSItem
        continue
    }
    '*Warning*'
    {
        Write-Warning -Message $PSItem
        continue
    }
    default
    {
        Write-Output $PSItem
    }
}
#######################################################################
<#
A break statement will exit the switch. This is the same behavior that continue will present for single values. 
The big difference is when processing an array. 
break will stop all processing in the switch and continue will move onto the next item.
#>
$Messages = @(
        'Downloading update'
        'Ran into errors downloading file'
        'Error: out of disk space'
        'Sending email'
        '...'
    )

    switch -Wildcard ($Messages)
    {
        'Error*'
        {
            Write-Error -Message $PSItem
            break
        }
        '*Error*'
        {
            Write-Warning -Message $PSItem
            continue
        }
        '*Warning*'
        {
            Write-Warning -Message $PSItem
            continue
        }
        default
        {
            Write-Output $PSItem
        }
    }

    # Output 
    Downloading update
    WARNING: Ran into errors downloading file
    write-error -message $PSItem : Error: out of disk space
    + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
    + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException

<#In this case, if we hit any lines that start with Error then we will get an error and the switch will stop. 
This is what that break statement is doing for us. If we find Error inside the string and not just at the beginning, we will write it as a warning. 
We will do the same thing for Warning. 
It is possible that a line could have both the word Error and Warning, but we only need one to process. 
This is what the continue statement is doing for us.#>
#######################################################################
:filelist foreach($path in $logs)
    {
        :logFile switch -Wildcard -File $path
        {
            'Error*'
            {
                Write-Error -Message $PSItem
                break filelist
            }
            'Warning*'
            {
                Write-Error -Message $PSItem
                break logFile
            }
            default
            {
                Write-Output $PSItem
            }
        }
    }
#######################################################################
<#
PowerShell 5.0 gave us enums and we can use them in a switch.
#>
enum Context {
    Component
    Role
    Location
}

$item = [Context]::Role

switch ( $item )
{
    Component
    {
        'is a component'
    }
    Role
    {
        'is a role'
    }
    Location
    {
        'is a location'
    }
}

# Output
is a role
#######################################################################
switch ($item )
    {
        ([Context]::Component)
        {
            'is a component'
        }
        ([Context]::Role)
        {
            'is a role'
        }
        ([Context]::Location)
        {
            'is a location'
        }
    }
<#
This adds a lot of complexity and can make your switch hard to read. 
In most cases where you would use something like this it would be better to use if and elseif statements. 
I would consider using this if I already had a large switch in place and I needed 2 items to hit the same evaluation block.
One thing that I think helps with legibility is to place the scriptblock in parentheses.
#>

    switch ( $age )
    {
        ({$PSItem -le 18})
        {
            'child'
        }
        ({$PSItem -gt 18})
        {
            'adult'
        }
    }
#######################################################################
<#
We need to revisit regex to touch on something that is not immediately obvious. 
The use of regex populates the $matches variable. I do go into the use of $matches more when I talk about The many ways to use regex. 
Here is a quick sample to show it in action with named matches.
#>
$message = 'my ssn is 123-23-3456 and credit card: 1234-5678-1234-5678'

    switch -regex ($message)
    {
        '(?<SSN>\d\d\d-\d\d-\d\d\d\d)'
        {
            Write-Warning "message contains a SSN: $($matches.SSN)"
        }
        '(?<CC>\d\d\d\d-\d\d\d\d-\d\d\d\d-\d\d\d\d)'
        {
            Write-Warning "message contains a credit card number: $($matches.CC)"
        }
        '(?<Phone>\d\d\d-\d\d\d-\d\d\d\d)'
        {
            Write-Warning "message contains a phone number: $($matches.Phone)"
        }
    }

    # Output
    WARNING: message may contain a SSN: 123-23-3456
    WARNING: message may contain a credit card number: 1234-5678-1234-5678
#######################################################################
<#
You can match a $null value that does not have to be the default.
#>
$value = $null

switch ( $value )
{
    $null
    {
        'Value is null'
    }
    default
    {
        'value is not null'
    }
}
# Output
Value is null


<#
Same goes for an empty string.
#>

switch ( '' )
    {
        ''
        {
            'Value is empty'
        }
        default
        {
            'value is a empty string'
        }
    }

    # Output
    Value is empty
#######################################################################
$isVisible = $false
$isEnabled = $true
$isSecure = $true

switch ( $true )
{
    $isEnabled
    {
        'Do-Action'
    }
    $isVisible
    {
        'Show-Animation'
    }
    $isSecure
    {
        'Enable-AdminMenu'
    }
}

# Output
Do-Action
Enabled-AdminMenu
#######################################################################
<#
Setting $isEnabled to $true in this example will make sure the $isVisible is also set to $true. 
Then when the $isVisible gets evaluated, its scriptblock will be invoked. 
This is a bit counter-intuitive but is a very clever use of the mechanics.
#>
$isVisible = $false
    $isEnabled = $true
    $isAdmin = $false

    switch ( $true )
    {
        $isEnabled
        {
            'Do-Action'
            $isVisible = $true
        }
        $isVisible
        {
            'Show-Animation'
        }
        $isAdmin
        {
            'Enable-AdminMenu'
        }
    }

    # Output
    Do-Action
    Show-Animation
#######################################################################
#######################################################################
