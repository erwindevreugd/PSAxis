function Restart-Server {
    [CmdletBinding()]
    param (
        [Parameter(
            Position=0, 
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true
        )]
        [string]$Host = $Script:Host,

        [Parameter(
            Position=1, 
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true
        )]
        [ValidateNotNull()]
        [System.Management.Automation.Credential()]
        [pscredential]$Credential = [PSCredential]::Empty,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true
        )]
        [VapixVersion]$VapixVersion = [VapixVersion]::Vapix3,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true
        )]
        [switch]$UseSSL = $Script:UseSSL,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true
        )]
        [switch]$IgnoreCertificateErrors = $Script:IgnoreCertificateErrors
    )
    
    begin {
        if($IgnoreCertificateErrors) {
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        }
    }
    
    process {
        $endPoint       = if($VapixVersion -eq [VapixVersion]::Vapix3 ) {"axis-cgi/restart.cgi"} else {"axis-cgi/restart.cgi"}
        $method         = "GET"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"

        Write-Verbose -Message "$($method) $($uri)"

        $message = @{
            Uri=$uri;
            Method=$method;
            UseBasicParsing=$true;
        }
        if ($Credential -ne [pscredential]::Empty) {
            $message.Add("Credential", $Credential)
        }
        Invoke-RestMethod @message | Out-Null
    }

    end {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $null }
    }
}