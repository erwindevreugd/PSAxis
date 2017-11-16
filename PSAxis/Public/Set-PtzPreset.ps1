function Set-PtzPreset {
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
        [switch]$IgnoreCertificateErrors = $Script:IgnoreCertificateErrors,

        [Parameter(
            
        )]
        [string]
        $PresetName
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
            gotoserverpresetname="$($PresetName)";
        }

        # Goto preset by name: gotoserverpresetname
        # Goto preset by id: gotoserverpresetno
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