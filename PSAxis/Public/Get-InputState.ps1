function Get-InputState {
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
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true
        )]
        [int]$InputId = $null
    )
    
    begin {
        if($IgnoreCertificateErrors) {
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        }
    }
    
    process {
        # http://192.168.1.36/axis-cgi/io/input.cgi?checkactive=1
        $endPoint       = "axis-cgi/io/input.cgi"
        $method         = "GET"
        # $contentType    = "application/json"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"

        $query = @{
            "checkactive"=$("${InputId}");
        }

        Write-Verbose -Message "$($method) $($uri)"
        Write-Verbose -Message "Query:`n$(ConvertTo-Json $query)"

        $message = @{
            Uri=$uri;
            Method=$method;
            Body=$query;
            UseBasicParsing=$true;
        }
        $response = Invoke-RestMethod @message -Credential $Credential
        $response
    }

    end {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $null }
    }
}