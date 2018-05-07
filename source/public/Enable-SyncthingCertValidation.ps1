function Enable-SyncthingCertValidation {
    <#
    .SYNOPSIS
        Enables SSL certificate validation.
    .DESCRIPTION
        Enables SSL certificate validation for the session. Note that this is
        not limited to SSL validation for Syncthing but for the entire session.
    .EXAMPLE
        Enable-SyncthingCertValidation

        Enables SSL certificate validation for the session.
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        Project : PSSyncthing (https://github.com/pauby/pssyncthing)
        History : 1.0 - 07/05/18 - Initial release
    .LINK
        Disable-SyncthingCertificateValidation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    Param ()

    #TODO This needs to be written - code left here deliberately but this
    # disables the validation
    if ($PSCmdlet.ShouldProcess('SSL Certificate Validation', 'Disable')) {
        # if we do not ignore certificate validation then self-signed
        # certificates will throw up errors - this code ignore the certificate
        # validation - taken from
        # https://blog.ukotic.net/2017/08/15/could-not-establish-trust-relationship-for-the-ssltls-invoke-webrequest/
        if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type) {
            $certCallback = @"
using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
public class ServerCertificateValidationCallback
{
    public static void Ignore()
    {
        if(ServicePointManager.ServerCertificateValidationCallback ==null)
        {
            ServicePointManager.ServerCertificateValidationCallback += 
                delegate
                (
                    Object obj, 
                    X509Certificate certificate, 
                    X509Chain chain, 
                    SslPolicyErrors errors
                )
                {
                    return true;
                };
        }
    }
}
"@
            Add-Type $certCallback
        }
        [ServerCertificateValidationCallback]::Ignore()
    }
}