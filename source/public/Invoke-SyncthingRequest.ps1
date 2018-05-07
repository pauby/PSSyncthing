function Invoke-SyncthingRequest {
    <#
    .SYNOPSIS
        Invokes a REST request to Syncthing.
    .DESCRIPTION
        Invokes a REST request to Syncthing running on a computer.

        If you need to disable Syncthing SSL certificate validation use the Diable-SyncthingCertValidation
    .EXAMPLE
        Invoke-SyncthingRequest -ApiKey 'abc123' -EndPoint '/system/browse'

        Invoke a REST request to localhost on port 8384 at endpoint /rest/system/browse using the api key 'abc123'.
    .EXAMPLE
        Invoke-SyncthingRequest -ComputerName 'server01' -Port 8090 -ApiKey 'abc' -Endpoint '/system/config' -EndpointParameter @{ 'current' = 'var' }

        Invoke a REST request to server01 on port 8090 using api key 'abc' and connecting to the endpoint /system/config with a parameter of current=var. 
    .OUTPUTS
        [PSCustomObject]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        Project : PSSyncthing (https://github.com/pauby/PSSyncthing)
        History : 1.0 - 03/05/18 - Initial release
    #>

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    Param (
        # ComputerName to connect to that has Syncthing running. Defaults to 'localhost'.
        [Parameter(ValueFromPipelineByPropertyName)]
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
        $ApiKey,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Get', 'Post')]
        [string]
        $Method = 'Get',

        # The REST endpoint to contact. Make sure to omit the intiial '/rest' -
        # so endpoint '/rest/system/browse' should just be '/system/browse'
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Endpoint,

        # Parameters to be passed to the endpoint. This should be in the @{ key
        # = value } format (ie. a hashtable).
        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable]
        $EndpointParameter
    )

    # the Headers parameter needs a hashtable so lets create one with
    # Syncthing's API Key
    $header = @{ 'X-API-Key' = $ApiKey }
    $msg = $header | ForEach-Object { "$($_.keys) = $($_.values);" }
    Write-Verbose "Syncthing REST request header is: $msg"

    # lets build up the Uri
    $uri = "http://$($ComputerName):$($Port)/rest$Endpoint"

    # if there are any parameters then create the query string
    if ($EndpointParameter) {
        $uri += '?'
        $count = 0
        ForEach ($k in $EndpointParameter.Keys) {
            if ($count -gt 0) {
                $uri += '&'
            }

            $uri += "$k=$($EndpointParameter.$k)"
            $count++
        }
    }
    
    Write-Verbose "Invoking REST request to Syncthing on computer '$ComputerName', port '$Port' using '$Method' method to Uri '$uri'."
    $params = @{
        Method          = $Method
        Uri             = $uri
        Headers         = $header
        UseBasicParsing = $true
    }
    Invoke-RestMethod @params 
}