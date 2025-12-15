# PowerShell script to add browser extension registry policies
# This script adds registry keys for Chrome and Edge extensions to allow noFiltering for domains

[CmdletBinding()]
param()

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Error "This script requires Administrator privileges. Please run PowerShell as Administrator."
    throw "Insufficient privileges"
}

Write-Output "Adding browser extension registry policies..."

try {
    # Chrome extension registry key
    $chromeKeyPath = "HKLM:\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\ddkjiahejlhfcafbddmgiahcphecmpfh\policy"
    
    # Create Chrome registry path if it doesn't exist
    if (-not (Test-Path $chromeKeyPath)) {
        Write-Verbose "Creating Chrome extension policy registry path..."
        New-Item -Path $chromeKeyPath -Force | Out-Null
    }
    
    # Set Chrome noFiltering value
    Write-Verbose "Setting Chrome noFiltering policy"
    Set-ItemProperty -Path $chromeKeyPath -Name "noFiltering" -Value '["DOMAIN.COM"]' -Type String
    
    # Edge extension registry key
    $edgeKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\cimighlppcgcoapaliogpjjdehbnofhn\policy"
    
    # Create Edge registry path if it doesn't exist
    if (-not (Test-Path $edgeKeyPath)) {
        Write-Verbose "Creating Edge extension policy registry path..."
        New-Item -Path $edgeKeyPath -Force | Out-Null
    }
    
    # Set Edge noFiltering value
    Write-Verbose "Setting Edge noFiltering policy for "
    Set-ItemProperty -Path $edgeKeyPath -Name "noFiltering" -Value '["DOMAIN.COM"]' -Type String
    
    Write-Output "Registry keys successfully added!"
    Write-Output "Chrome extension policy: $chromeKeyPath"
    Write-Output "Edge extension policy: $edgeKeyPath"
    
    # Verify the changes
    Write-Verbose "Verifying registry entries..."
    
    $chromeValue = Get-ItemProperty -Path $chromeKeyPath -Name "noFiltering" -ErrorAction SilentlyContinue
    if ($chromeValue) {
        Write-Output "✓ Chrome noFiltering: $($chromeValue.noFiltering)"
    } else {
        Write-Warning "Chrome registry entry not found"
    }
    
    $edgeValue = Get-ItemProperty -Path $edgeKeyPath -Name "noFiltering" -ErrorAction SilentlyContinue
    if ($edgeValue) {
        Write-Output "✓ Edge noFiltering: $($edgeValue.noFiltering)"
    } else {
        Write-Warning "Edge registry entry not found"
    }
    
    Write-Warning "Browser restart may be required for policies to take effect."
    
} catch {
    Write-Error "Failed to add registry keys: $($_.Exception.Message)"
    throw 1
}

Write-Output "Script completed successfully."
