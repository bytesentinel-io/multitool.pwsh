Import-Module AzureAD

$LocalUser = $env:USERNAME
$LocalDomain = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).Name

function Search-Permissions {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Group
    )
    try {
        # If user is member of the ad group (local), add to distribution list
        $group = Get-ADGroup -Identity $Group -ErrorAction Stop -WarningAction SilentlyContinue
        $user = Get-ADUser -Identity $LocalUser -Filter { MemberOf -RecursiveMatch $group.DistinguishedName } -ErrorAction Stop -WarningAction SilentlyContinue
        if ($user) {
            Write-Host -ForegroundColor Green "User $LocalUser is member of group $Group!"
        } else {
            Write-Host -ForegroundColor Red "User $LocalUser is not member of group $Group!"
        }
    }
    catch {
        Write-Error -Category ObjectNotFound -Message "Group $Group not found in domain $LocalDomain!"
    }
}

function Authenticate {
    param (
        [Parameter(Mandatory=$false)]
        [string]$Domain
    )
    if ($Domain) {
        Write-Host -ForegroundColor Yellow "Using domain $Domain..."
        $UserPrincipalName = $LocalUser + "@$Domain"
    } else {
        Write-Host -ForegroundColor Yellow "Using local domain..."
        $UserPrincipalName = $LocalUser + "@$LocalDomain"
    }
    # Use the logged on user to authenticate to Azure AD
    Write-Host -ForegroundColor Yellow "Authenticating as $UserPrincipalName to Azure AD..."
    try {   
        Connect-AzureAD -AccountId $UserPrincipalName -ErrorAction Stop | Out-Null
        Write-Host -ForegroundColor Green "Successfully authenticated to Azure AD!"
    }
    catch {
        Write-Error -Category ConnectionError -Message "Failed to authenticate to Azure AD!"
    }
    # Check if user is member of the group in the local domain
    Search-Permissions -Group "Domain Admins"
}

Authenticate # -Domain "bytesentinel.io"