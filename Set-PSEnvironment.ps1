# if running on Windows OS
if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {

    # install powershell 7+
    if ([int] ($PSVersionTable.PSVersion.Major.ToString() + $PSVersionTable.PSVersion.Minor.ToString()) -lt 72) {
        # fetchs installation script from powershell github. the installation GUI will pop up.
        Write-Host "Trying to install Powershell 7+ is now..."
        Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -EnablePSRemoting -AddExplorerContextMenu"
    }

    # install az modules if it does not exist.
    if ($null -eq (Get-InstalledModule -Name Az -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Az Modules..."
        Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -AllowClobber -Force -SkipPublisherCheck
    }

    # remove AzureRm modules if exists..
    if (-not $null -eq (Get-InstalledModule -Name "AzureRm" -ErrorAction SilentlyContinue)) {
        Write-Host "Uninstalling AzureRm Modules..."
        Uninstall-AzureRm
    }
}
