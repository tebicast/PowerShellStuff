configuration Name
{
    # One can evaluate expressions to get the node list
    # E.g: $AllNodes.Where("Role -eq Web").NodeName
    node ("Node1","Node2","Node3")
    {
        # Call Resource Provider
        # E.g: WindowsFeature, File
        WindowsFeature FriendlyName
        {
           Ensure = "Present"
           Name   = "Feature Name"
        }

        File FriendlyName
        {
            Ensure          = "Present"
            SourcePath      = $SourcePath
            DestinationPath = $DestinationPath
            Type            = "Directory"
            DependsOn       = "[WindowsFeature]FriendlyName"
        }       
    }
}
########################################################################################
configuration ConfigurationName
{
    # One can evaluate expressions to get the node list
    # E.g: $AllNodes.Where("Role -eq Web").NodeName
    node $AllNodes.Where{$_.Role -eq "WebServer"}.NodeName
    {
        # Call Resource Provider
        # E.g: WindowsFeature, File
        WindowsFeature FriendlyName
        {
           Ensure = "Present"
           Name   = "Feature Name"
        }

        File FriendlyName
        {
            Ensure          = "Present"
            SourcePath      = $SourcePath
            DestinationPath = $DestinationPath
            Type            = "Directory"
            DependsOn       = "[WindowsFeature]FriendlyName"
        }       
    }
}

# ConfigurationName -configurationData <path to ConfigurationData (.psd1) file>
########################################################################################

@{
    AllNodes = @(
        @{
            NodeName = "Node1"
            Role = "WebServer"
            },
        @{
            NodeName = "Node2"
            Role = "SQLServer"
            },
        @{
            NodeName = "Node3"
            Role = "WebServer"
            }
    )
}
# Save ConfigurationData in a file with .psd1 file extension
########################################################################################
Function Get-TargetResource
{
    # TODO: Add parameters here
    # Make sure to use the same parameters for
    # Get-TargetResource, Set-TargetResource, and Test-TargetResource
    param(
    )
}

Function Set-TargetResource
{
    # TODO: Add parameters here
    # Make sure to use the same parameters for
    # Get-TargetResource, Set-TargetResource, and Test-TargetResource
    param(
    )
}

Function Test-TargetResource
{
    # TODO: Add parameters here
    # Make sure to use the same parameters for
    # Get-TargetResource, Set-TargetResource, and Test-TargetResource
    param(
    )
}

########################################################################################
# Defines the values for the resource's Ensure property.
enum Ensure
{
    # The resource must be absent.    
    Absent
    # The resource must be present.    
    Present
}

# [DscResource()] indicates the class is a DSC resource.
[DscResource()]
class NameOfResource
{

    # A DSC resource must define at least one key property.
    [DscProperty(Key)]
    [string]$P1

    # Mandatory indicates the property is required and DSC will guarantee it is set.
    [DscProperty(Mandatory)]
    [Ensure] $P2

    # NotConfigurable properties return additional information about the state of the resource.
    # For example, a Get() method might return the date a resource was last modified.
    # NOTE: These properties are only used by the Get() method and cannot be set in configuration.        
    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $P3

    [DscProperty()]
    [ValidateSet("val1", "val2")]
    [string] $P4
    
    # Sets the desired state of the resource.
    [void] Set()
    {        
    }        
    
    # Tests if the resource is in the desired state.
    [bool] Test()
    {        
        return $true
    }    
    # Gets the resource's current state.
    [NameOfResource] Get()
    {        
        # NotConfigurable properties are set in the Get method.
        $this.P3 = something
        # Return this instance or construct a new instance.
        return $this 
    }    
}