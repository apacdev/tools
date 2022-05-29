function Set-PSEnvironment() {
     if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
        if ($true -eq (Test-Path 'HKLM:\SOFTWARE\Microsoft\PowerShellCore')) {
        
            Write-Host 'The installation of Powershell 7 is found on your machine.'

            pwsh -NoProfile -ExecutionPolicy ByPass -Command {

                If ($null -eq (Get-InstalledModule -Name Az -ErrorAction SilentlyContinue)) {
                
                    Write-Host 'Az modules are not found.  Installing the modules now. This may take a while...'
                    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -AllowClobber -Force -SkipPublisherCheck -PassThru
                
                } else {

                    Write-Output 'Az modules are found. You are good to go!'
                }

                if (-not $null -eq (Get-InstalledModule -Name AzureRM -ErrorAction SilentlyContinue)) {

                    Write-Host 'AzureRM is found, and it is about to be removed. You need to give an administrator access if prompted.'
                    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
                            Write-Host "Uninstalling AzureRm Modules. This will take a while..."
                            Uninstall-AzureRM -PassThru
                    }
                }
            }
        }
        else {
                Write-Host 'The installation of Powershell 7 is not found on your machine. This will be installed...'
                Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -EnablePSRemoting -AddExplorerContextMenu"
                Write-Host 'Powershell 7 is now installed on your machine.  Please CLOSE and REOPEN the current PowerShell window, then run the script again.'
        }
    }
}

Set-PSEnvironment
