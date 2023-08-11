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