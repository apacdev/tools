# tools

[DESCRIPTION]

The script retrieves quota usage vs. approaved across all subscriptions under your Azure tenant.  It generates two output file: 1) all_subscriptions.csv, and 2) quotautil.zip.  The first includes quota information of all subscriptions and regions in a single file while the second one has csv files from each subscriptions in a zip format.

[PREREQUISITE]

The script is tested on PowerShell 7.0 with Az Modules installed.

[USAGE]

Simply fetch this quota_profiler.ps1 to your local drive and run it in your powershell.  You can also run the script directly from this repo by running the following command at your powershell prompt: 

    (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/quota_profiler.ps1'))"

[REFERENCE]

A quick and dirty way to check the running envinroment and setup.

    function Set-PSEnvironment {
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
    }
    Set-PSEnvironment
