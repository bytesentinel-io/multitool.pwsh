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
    $content = Get-Content -Path $Path -ErrorAction Stop
    $lines = $content | Select-String -Pattern $SearchPattern
    if ($lines.Count -gt 0) {
        Write-Host "Found $($lines.Count) lines in $($Path)!"
        foreach ($line in $lines) {
            $lineNumber = $line.LineNumber
            Add-ResultToCsv -Path $Path -Line $lineNumber
        }
    }
}

function Find-AllFiles {
    param (
        [Parameter(Mandatory=$false)]
        [string]$Path = $PWD,
        [Parameter(Mandatory=$true)]
        [string]$SearchPattern
    )
    $files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction Stop
    if ($files.Count -eq 0) {
        Write-Host "No files found in $Path"
        return
    }
    Write-Host "Found $($files.Count) files in $($Path)! Searching for pattern $($SearchPattern)..."
    foreach ($file in $files) {
        Search-TextInFiles -Path $file.FullName -SearchPattern $SearchPattern
    }
}

$SearchPath = "C:\"
$SearchPattern = "bytesentinel"
Find-AllFiles -Path $SearchPath -SearchPattern $SearchPattern