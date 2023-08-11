Import-Module AzureAD

$LocalUser = $env:USERNAME
$LocalDomain = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).Name

function Search-Permissions {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Group
    )
    try {
        $GroupId = (Get-ADGroup -Identity $Group).ObjectGUID
        if ($GroupId) {
            Write-Host -ForegroundColor Yellow "Group $($Group) found in domain $($LocalDomain)!"
        } else {
            Write-Error -Category ObjectNotFound -Message "Group $($Group) not found in domain $($LocalDomain)!"
        }
        $GroupMembers = Get-ADGroupMember -Identity $GroupId -Recursive | Select-Object -ExpandProperty SamAccountName
        if ($LocalUser -in $GroupMembers) {
            Write-Host -ForegroundColor Green "User $($env:USERNAME) is member of group $($Group) in domain $($LocalDomain)!"
        } else {
            Write-Host -ForegroundColor Red "User $($env:USERNAME) is not member of group $($Group) in domain $($LocalDomain)!"
        }
    }
    catch {
        Write-Error -Category ObjectNotFound -Message "Group $($Group) not found in domain $($LocalDomain)!"
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

Authenticate -Domain "bytesentinel.io"