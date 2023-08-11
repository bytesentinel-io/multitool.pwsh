Import-Module AzureAD

function Authenticate {
    param (
        [Parameter(Mandatory=$false)]
        [string]$Domain = ""
    )
    # Use the logged on user to authenticate to Azure AD
    $UserPrincipalName = $env:USERNAME + ($Domain -ne "" ? "@$Domain" : "")
    Write-Host -ForegroundColor Yellow "Authenticating as $UserPrincipalName to Azure AD..."
    try {   
        Connect-AzureAD -AccountId $UserPrincipalName -ErrorAction Stop
        Write-Host -ForegroundColor Green "Successfully authenticated to Azure AD!"
    }
    catch {
        Write-Error -Category ConnectionError -Message "Failed to authenticate to Azure AD!"
    }
}

Authenticate -Domain "bytesentinel.io"