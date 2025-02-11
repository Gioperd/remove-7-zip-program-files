<#
.SYNOPSIS
    Removes 7-Zip program files that create a high-level vulnerability on Windows Server 2019.
    Please test thoroughly in a non-production environment before deploying widely.
    Make sure to run as Administrator or with appropriate privileges.

.NOTES
    Author        : Giovanni Perdomo Dubon
    Date Created  : 2025-02-11
    Last Modified : 2025-02-11
    Version       : 1.1

.TESTED ON
    Date(s) Tested  : 2025-02-11
    Tested By       : Giovanni
    Systems Tested  : Windows Server 2019 Datacenter, Build 1809
    PowerShell Ver. : 5.1.17763.6766

.USAGE
    Example syntax:
    PS C:\> .\remove-7-zip.ps1
#>

# Define log file path
$logFile = "C:\remove-7-zip.log"

# Function to log actions
function Log-Action {
    param (
        [string]$message,
        [string]$logLevel = "INFO"
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "[$timestamp] [$logLevel] $message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

# Check if 7-Zip is installed
$sevenZipPath = "C:\Program Files\7-Zip"
$uninstaller = Join-Path $sevenZipPath "Uninstall.exe"

# Check if 7-Zip directory exists
if (Test-Path $sevenZipPath) {
    Log-Action "7-Zip installation directory found: $sevenZipPath"

    # Confirm with user before proceeding with uninstallation
    $confirmation = Read-Host "Are you sure you want to remove 7-Zip? (Y/N)"
    if ($confirmation -ne "Y") {
        Log-Action "Uninstallation aborted by user." "WARNING"
        Write-Host "Uninstallation aborted." -ForegroundColor Red
        return
    }

    # Attempt to uninstall 7-Zip if uninstaller exists
    if (Test-Path $uninstaller) {
        Log-Action "Running 7-Zip uninstaller..."
        try {
            & $uninstaller /S
            Start-Sleep -Seconds 10
            Log-Action "7-Zip uninstaller executed successfully."
        } catch {
            Log-Action "Error running uninstaller: $_" "ERROR"
            Write-Host "Error running uninstaller. Attempting manual removal..." -ForegroundColor Yellow
        }
    } else {
        Log-Action "Uninstaller not found. Attempting to remove 7-Zip manually." "WARNING"
    }

    # Clean up the 7-Zip directory manually if necessary
    Write-Host "Cleaning up 7-Zip directory..." -ForegroundColor Yellow
    try {
        Remove-Item -Recurse -Force $sevenZipPath -ErrorAction Stop
        Log-Action "7-Zip directory removed successfully."
        Write-Host "7-Zip has been successfully removed." -ForegroundColor Green
    } catch {
        Log-Action "Failed to remove 7-Zip directory. Error: $_" "ERROR"
        Write-Host "Failed to remove 7-Zip directory. Please check logs for details." -ForegroundColor Red
    }

} else {
    Log-Action "7-Zip is not installed."
    Write-Host "7-Zip is not installed." -ForegroundColor Red
}
