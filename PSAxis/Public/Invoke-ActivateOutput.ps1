function Invoke-ActivateOutput {
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
        [pscredential]$Credential,

        [Parameter(
            ValueFromPipelineByPropertyName=$true
        )]
        [switch]$UseSSL = $Script:UseSSL,

        [Parameter(
            ValueFromPipelineByPropertyName=$true
        )]
        [switch]$IgnoreCertificateErrors = $Script:IgnoreCertificateErrors,

        [Parameter(
            Mandatory=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [int]$OutputId
    )
    
    begin {
        if($IgnoreCertificateErrors) {
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        }
    }
    
    process {
        # http://192.168.1.36/axis-cgi/io/output.cgi?action=1:/
        $endPoint       = "axis-cgi/io/output.cgi"
        $method         = "GET"
        # $contentType    = "application/json"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"

        $query = @{
            action=$("${OutputId}:/");
        }

        Write-Verbose -Message "$($method) $($uri)"
        Write-Verbose -Message "Query:`n$(ConvertTo-Json $query)"

        $message = @{
            Uri=$uri;
            Method=$method;
            Body=$query;
            UseBasicParsing=$true;
        }
        Invoke-RestMethod @message -Credential $Credential | Out-Null
    }

    end {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $null }
    }
}