# Save matches to a csv file
function Add-ResultToCsv {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [string]$Line,
        [Parameter(Mandatory=$false)]
        [string]$OutputFile = "output.csv"
    )
    # Save to csv - Path,Line
    # Check if file not exists, create it
    if (!(Test-Path -Path $OutputFile)) {
        New-Item -Path $OutputFile -ItemType File
    }
    # Check if file is empty, add header
    if ((Get-Content -Path $OutputFile).Count -eq 0) {
        Add-Content -Path $OutputFile -Value "Hostname;Path;Line"
    }
    # Add content
    Add-Content -Path $OutputFile -Value "$($env:COMPUTERNAME);$Path;$Line"
}

# Function to check content if content a specific pattern
function Search-TextInFiles {
    param (
        [Parameter(Mandatory=$false)]
        [string]$Path = $PWD,
        [Parameter(Mandatory=$true)]
        [string]$SearchPattern
    )
    try {
        $content = Get-Content -Path $Path -ErrorAction Stop
        $lines = $content | Select-String -Pattern $SearchPattern
        if ($lines.Count -gt 0) {
            Write-Host "Found $($lines.Count) lines in $($Path)!"
            foreach ($line in $lines) {
                $lineNumber = $line.LineNumber
                Add-ResultToCsv -Path $Path -Line $lineNumber
            }
        }
    } catch {
        Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)"
    }
}

function Replace-TextInFiles {
    param (
        [Parameter(Mandatory=$false)]
        [string]$Path = $PWD,
        [Parameter(Mandatory=$true)]
        [string]$SearchPattern,
        [Parameter(Mandatory=$true)]
        [string]$ReplacePattern
    )
    try {
        $content = Get-Content -Path $Path -ErrorAction Stop
        $lines = $content | Select-String -Pattern $SearchPattern
        if ($lines.Count -gt 0) {
            Write-Host "Found $($lines.Count) lines in $($Path)! Replacing pattern $($SearchPattern) with $($ReplacePattern)..."
            foreach ($line in $lines) {
                $lineNumber = $line.LineNumber
                $newContent = $content -replace $SearchPattern, $ReplacePattern
                Set-Content -Path $Path -Value $newContent
                Write-Host "Replaced pattern $($SearchPattern) with $($ReplacePattern) in $($Path) on line $($lineNumber)!"
            }
        }
    } catch {
        Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)"
    }
}

function Find-AllFiles {
    param (
        [Parameter(Mandatory=$false)]
        [string]$Path = $PWD,
        [Parameter(Mandatory=$true)]
        [string]$SearchPattern,
        [Parameter(Mandatory=$false)]
        [array]$ExcludeExtensions = ""
    )
    try {
        $files = Get-ChildItem -Path $Path -Recurse -File | Where-Object { $_.Extension -notcontains $ExcludeExtensions }
        if ($files.Count -eq 0) {
            Write-Host "No files found in $Path"
            return
        }
        Write-Host "Found $($files.Count) files in $($Path)! Searching for pattern $($SearchPattern)..."
        foreach ($file in $files) {
            # Search-TextInFiles -Path $file.FullName -SearchPattern $SearchPattern
            # Replace-TextInFiles -Path $file.FullName -SearchPattern $SearchPattern -ReplacePattern "test"
        }
    }
    catch {
        Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)"
    }
}

$SearchPath = "C:\"
$SearchPattern = "bytesentinel"
# Exclude all images
$excludedExtensions = @(".jpg", ".png", ".gif", ".bmp", ".mp4", ".avi", ".xlsx", ".docx", ".pdf", ".zip")
Find-AllFiles -Path $SearchPath -SearchPattern $SearchPattern -ExcludeExtensions $excludedExtensions
