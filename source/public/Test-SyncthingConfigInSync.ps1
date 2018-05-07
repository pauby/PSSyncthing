function Test-SyncthingConfigInSync {
    <#
    .SYNOPSIS
        Tests whether Syncthing configuration is in sync.
    .DESCRIPTION
        Tests whther Syncthings the running configuration is in sync with the
        configuration on disk.
    .EXAMPLE
        Test-SyncthingConfigInSync -ApiKey 'abc123'

        Tests if the running configuration of Syncthing on the local computer using api key abc123 is the same as that on disk, or $false is not.
    .EXAMPLE
        Test-SyncthingConfigInSync -ComputerName 'server01' -Port 8090 -ApiKey 'abc' -ValidateCertificate

        Tests if the running configuration of Syncthing on computer server01, port 8090 using api key 'abc' and validating the Syncthing SSL certificate is the same as the configuration on disk.
    .OUTPUTS
        [Boolean] of $true if the running configuration is the same as that on disk and $false otherwise.
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        Project : PSSyncthing (https://github.com/pauby/PSSyncthing)
        History : 1.0 - 07/05/18 - Initial release
    #>

    [OutputType([Boolean])]
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
            Endpoint            = '/system/config/insync'
        }
    }

    Process {
        ForEach ($name in $ComputerName) {
            Write-Verbose "Checking configuration sync status of '$name'."
            $params.ComputerName = $name

            try {
                $response = Invoke-SyncthingRequest @params
            }
            catch {
                Write-Verbose "Had a problem getting the configuration of Syncthing on '$name'."
                return $null
            }

            return $response.configInSync
        }
    }

}