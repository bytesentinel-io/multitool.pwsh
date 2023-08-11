function Get-NetworkShareDfsTarget {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    $DfsServer = Get-DfsnFolderTarget -Path $Path | Where-Object State -eq Online | Select-Object -ExpandProperty TargetPath
    if ($DfsServer) {
        Write-Host -ForegroundColor Green "Found DFS server $DfsServer for path $Path!"
        return $DfsServer
    } else {
        Write-Host -ForegroundColor Red "Failed to find DFS server for path $Path!"
        return $false
    }
}

function Get-OpenFilesOnDfs {
    param (
        [Parameter(Mandatory=$true)]
        [string]$DfsServer
    )
    $OpenFiles = Get-SmbOpenFile -ServerName $DfsServer | Select-Object -ExpandProperty Path
    if ($OpenFiles) {
        Write-Host -ForegroundColor Green "Found open files on DFS server $DfsServer!"
        return $OpenFiles
    } else {
        Write-Host -ForegroundColor Red "Failed to find open files on DFS server $DfsServer!"
        return $false
    }
}

function Close-OpenFilesOnDfs {
    param (
        [Parameter(Mandatory=$true)]
        [string]$DfsServer,
        [Parameter(Mandatory=$true)]
        [string]$OpenFiles
    )
    $OpenFiles | ForEach-Object {
        $OpenFile = $_
        Write-Host -ForegroundColor Yellow "Closing open file $OpenFile on DFS server $DfsServer..."
        try {
            Close-SmbOpenFile -ServerName $DfsServer -FileId $OpenFile -Force -ErrorAction Stop | Out-Null
            Write-Host -ForegroundColor Green "Successfully closed open file $OpenFile on DFS server $DfsServer!"
        }
        catch {
            Write-Error -Category OperationError -Message "Failed to close open file $OpenFile on DFS server $DfsServer!"
        }
    }
}

function Choice {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$true)]
        [string]$Choices
    )
    Write-Host -ForegroundColor Yellow $Message
    Write-Host -ForegroundColor Yellow $Choices
    $Choice = Read-Host
    if ($Choice -eq "y") {
        return $true
    } else {
        return $false
    }
}

function MultiChoice {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$true)]
        [array]$Choices
    )
    Write-Host -ForegroundColor Yellow $Message
    $ChoiceCount = 0
    $Choices | ForEach-Object {
        $ChoiceCount++
        Write-Host -ForegroundColor Yellow "$ChoiceCount. $($_.Question)"
    }
    $Choice = Read-Host -Prompt "`nEnter your choice (1-$ChoiceCount)"
    if ($Choice -ge 1 -and $Choice -le $ChoiceCount) {
        return $Choices[$Choice - 1].Action
    } else {
        return $false
    }
}

$Choices = @( 
    @{ Question = "Close open files on DFS"; Action = 1 }
    @{ Question = "Get open files on DFS"; Action = 2 }
    @{ Question = "Get DFS server for path"; Action = 3 }
)
$Choice = MultiChoice -Message "What do you want to do?`n" -Choices $Choices
switch ($Choice) {
    1 {
        Write-Host "Closing open files on DFS..."
    }
    2 {
        Write-Host "Getting open files on DFS..."
    }
    3 {
        Write-Host "Getting DFS server for path..."
    }
    default {
        Write-Host -ForegroundColor Red "Invalid choice!"
    }
}