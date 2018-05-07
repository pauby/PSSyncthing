function Get-SyncthingConfig {
    <#
    .SYNOPSIS
        Get's the configuration of Syncthing.
    .DESCRIPTION
        Get's the configuration of Syncthing on local or remote computers.
    .EXAMPLE
        Get-SyncthingConfig -ApiKey 'abc123'

        Returns the configuration of Syncthing on the local computer.
    .EXAMPLE
        Get-SyncthingConfig -ComputerName 'server01' -Port 8090 -ApiKey 'abc' -ValidateCertificate

        Get's the Syncthing configuration from computer server01 on port 8090 using api key 'abc' and validates the Syncthing SSL certificate. 
    .OUTPUTS
        [PSCustomObject] containing the configuration if we can connect to
        Syncthing. Otherwise we throw an exception.
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        Project : PSSyncthing (https://github.com/pauby/PSSyncthing)
        History : 1.0 - 07/05/18 - Initial release
    #>

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    Param (
        # ComputerName to connect to that has Syncthing running. Defaults to 'localhost'.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $ComputerName = 'localhost',

        # Port Syncthing is listening on. Defaults to '8384'.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(1, 65535)]
        [int]
        $Port = 8384,

        # Syncthing API Key to use to connect.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $ApiKey
    )
    
    Begin {
        $params = @{
            Port                = $Port
            ApiKey              = $ApiKey
            Endpoint            = '/system/config'
        }
    }

    Process {
        ForEach ($name in $ComputerName) {
            Write-Verbose "Getting Syncthing configuration from '$name'."
            $params.ComputerName = $name

            $response = Invoke-SyncthingRequest @params
            if ($null -eq $response) {
                return $null
            }
            else {
                return $response
            }
        }
    }
}