Import-Module AzureAD

function Authenticate {
    param (
        [Parameter(Mandatory=$false)]
        [string]$Domain
    )
    if ($Domain) {
        Write-Host -ForegroundColor Yellow "Using domain $Domain..."
        $UserPrincipalName = $env:USERNAME + "@$Domain"
    } else {
        Write-Host -ForegroundColor Yellow "Using local domain..."
        $LocalDomain = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).Name
        $UserPrincipalName = $env:USERNAME + "@$LocalDomain"
    }
    # Use the logged on user to authenticate to Azure AD
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