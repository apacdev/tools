# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
# ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
# PARTICULAR PURPOSE.
# CUSTOMER SUCCESS UNIT, MICROSOFT CORP. APAC.

##########################################################################################
# a quick and dirty way to check and setup running environment.
##########################################################################################

function Get-OSVersion() {
    if (([System.Environment]::OSVersion.Platform) -match 'Win32NT') { return 'WINDOWS'} 
    else { return 'NON-WINDOWS' }
}

function Get-PSVersion() {
    if (Test-Path 'HKLM:\SOFTWARE\Microsoft\PowerShellCore') { return $true } 
    else { return $false }
}

function Install-LatestPS7() {
    if (Get-OSVersion -eq 'WINDOWS') {

        if (Get-PSVersion) {
            Write-Host 'Powershell 7 is already installed on your Windows.' 
        } 
        else {
        
            Write-Host 'Powershell 7 is not found on your Windows. The installation will start...'
            
            try {
                # retrieves the latest powershell from the Microsoft repo.
                Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -EnablePSRemoting -AddExplorerContextMenu"
                Write-Host 'Please CLOSE and REOPEN the current CommandLine (or PowerShell) window, then run the script again if PowerShell 7.0 is successfully installed.'
                break;
            }
            catch {
                # there was an error in calling REST. 
                Write-Host 'An error occurred during pulling the data from the remote server.  Please try again later...'
            }
        }  
    } 
}

# install az modules if it does not exist on your machines.
function Install-AzModules() {
     # PowerShell 7 script block to install az modules on your system.
     pwsh -NoProfile -ExecutionPolicy ByPass -Command {
     
          # command block to see if az modules are not found for your PowerShell 7, it fetches and install them.
          If ($null -eq (Get-InstalledModule -Name Az -ErrorAction SilentlyContinue)) {
               Write-Host 'Az modules are not found.  Installing the modules now. This may take a while...'
               Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -AllowClobber -Force -SkipPublisherCheck -PassThru
          } 
          else {
               # az modules are already found in the system.
               Write-Output 'Az modules are found...'
          }
     }
}

# removes legacy AzureRM components to avoid conflicts with Az Modules.
function Remove-AzureRM() {
     # now, it is time to remove AzureRM modules.  
     if (-not $null -eq (Get-InstalledModule -Name AzureRM -ErrorAction SilentlyContinue)) {
          # Prompt the user and remove AzureRM modules with Admin Rights.
          Write-Host 'AzureRM is found, and it is about to be removed. You need to give an administrator access if prompted.'
          if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
               Write-Host "Uninstalling AzureRm Modules. This will take a while..."
               Uninstall-AzureRM -PassThru
          }
     }
     else {
        Write-host 'The legacy AzureRM is not found on your system (which means good!).'
     }
}

# aggregate all fuction calls.
function Set-PSEnvironment() {

    Install-LatestPS7
    Install-AzModules
    Remove-AzureRM
}

Set-PSEnvironment

Write-Host 'The setup of Prerequisites is now completed.  Please proceed with running the quota_profiler script as described in Usage section in README.'

