function Get-VideoStatus {
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
        [switch]$IgnoreCertificateErrors = $Script:IgnoreCertificateErrors,

        [Parameter(
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true
        )]
        [int[]]$Channel = 1
    )
    
    begin {
        if($IgnoreCertificateErrors) {
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        }
    }
    
    process {
        $endPoint       = if($VapixVersion -eq [VapixVersion]::Vapix3 ) {"axis-cgi/videostatus.cgi"} else {"axis-cgi/videostatus.cgi"}
        $method         = "GET"
        $uri            = "http" + $(if($UseSSL) { "s" }) + "://$($Host)/$($endPoint)"

        $query = @{
            status=$($Channel -join ",");
        }

        Write-Verbose -Message "$($method) $($uri)"
        Write-Verbose -Message "Query:`n$(ConvertTo-Json $query)"

        $message = @{
            Uri=$uri;
            Method=$method;
            Body=$query;
            UseBasicParsing=$true;
        }
        if ($Credential -ne [pscredential]::Empty) {
            $message.Add("Credential", $Credential)
        }
        $response = Invoke-RestMethod @message
        $response -split "\n" | ForEach-Object { ConvertFrom-String $_ -Delimiter "=" -PropertyNames Channel,Status  }
    }

    end {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $null }
    }
}