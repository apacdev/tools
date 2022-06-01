# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
# ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
# PARTICULAR PURPOSE.
# CUSTOMER SUCCESS UNIT, MICROSOFT CORP. APAC.

##########################################################################################
# a quick and dirty way to check and setup running environment.
##########################################################################################

function Set-PSEnvironment() {

     # check OS platform of the machine.
     if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
          # if Windows, then it peeks into Windows Registry to see if PowerShell 7 is installed.
          if ($true -eq (Test-Path 'HKLM:\SOFTWARE\Microsoft\PowerShellCore')) {
               # if PowerShell 7 is found, prompt the user, then use pwsh (instead of powershell) to get Az Modules installed with a command block.
               Write-Host 'The installation of Powershell 7 is found on your machine.'    
               pwsh -NoProfile -ExecutionPolicy ByPass -Command {
               
                    # if az modules are not found for your PowerShell 7, it fetches and install them.
                    If ($null -eq (Get-InstalledModule -Name Az -ErrorAction SilentlyContinue)) {
                         Write-Host 'Az modules are not found.  Installing the modules now. This may take a while...'
                         Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -AllowClobber -Force -SkipPublisherCheck -PassThru
                    } 
                    else {
                         Write-Output 'Az modules are found. You are good to go!'
                    }
                    
                    # now, it is time to remove AzureRM modules.  
                    if (-not $null -eq (Get-InstalledModule -Name AzureRM -ErrorAction SilentlyContinue)) {
                         # Prompt the user and remove AzureRM modules with Admin Rights.
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
