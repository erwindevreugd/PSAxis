function Get-PtzPreset {
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
        [VapixVersion]$VapixVersion = [VapixVersion]::Vapix3,

        [Parameter(
            ValueFromPipelineByPropertyName=$true
        )]
        [switch]$UseSSL = $Script:UseSSL,

        [Parameter(
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
        $endPoint       = if($VapixVersion -eq [VapixVersion]::Vapix3 ) {"axis-cgi/com/ptz.cgi"} else {"axis-cgi/com/ptz.cgi"}
        $method         = "GET"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"

        $query = @{
            query="presetposcam";
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
        $response -split "\n" | ForEach-Object { ConvertFrom-String $_ -Delimiter "=" -PropertyNames Position,Name  }
    }

    end {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $null }
    }
}