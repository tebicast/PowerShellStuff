while ($x -gt 0)
{
    
}
########################################################################################
do
{
    
}
until ($x -gt 0)
########################################################################################
do
{
    
}
while ($x -gt 0)
########################################################################################
for ($i = 1; $i -lt 99; $i++)
{ 
    
}
########################################################################################
foreach ($item in $collection)
{
    
}
########################################################################################
function MyFunction ($param1, $param2)
{
    
}
########################################################################################
if ($x -gt $y)
{
    
}
########################################################################################
if ($x -lt $y)
{
    
}
else
{
    
}
########################################################################################
switch ($x)
{
    'value1' {}
    {$_ -in 'A','B','C'} {}
    'value3' {}
    Default {}
}
########################################################################################
try
{
    
}
finally
{
    
}
########################################################################################
try
{
    1/0
}
catch [DivideByZeroException]
{
    Write-Host "Divide by zero exception"
}
catch [System.Net.WebException],[System.Exception]
{
    Write-Host "Other exception"
}
finally
{
    Write-Host "cleaning up ..."
}
########################################################################################
# Define a class
class TypeName
{
   # Property with validate set
   [ValidateSet("val1", "Val2")]
   [string] $P1

   # Static property
   static [hashtable] $P2

   # Hidden property does not show as result of Get-Member
   hidden [int] $P3

   # Constructor
   TypeName ([string] $s)
   {
       $this.P1 = $s       
   }

   # Static method
   static [void] MemberMethod1([hashtable] $h)
   {
       [TypeName]::P2 = $h
   }

   # Instance method
   [int] MemberMethod2([int] $i)
   {
       $this.P3 = $i
       return $this.P3
   }
}

