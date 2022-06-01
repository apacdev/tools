# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
# ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
# PARTICULAR PURPOSE.
# CUSTOMER SUCCESS UNIT, MICROSOFT CORP. APAC.

$datapath = "./quotautil"
$temppath = "/temp/script"
$sh_filename = "no-win-script.sh"

##########################################################################################
# a quick and dirty way to check and setup running environment.
##########################################################################################

function Install-AzModules() {

     Write-Host 'The installation of Powershell 7 is found on your machine.'    
     
     # PowerShell 7 script block to install az modules on your system.
     pwsh -NoProfile -ExecutionPolicy ByPass -Command {
          # command block to see if az modules are not found for your PowerShell 7, it fetches and install them.
          If ($null -eq (Get-InstalledModule -Name Az -ErrorAction SilentlyContinue)) {
               Write-Host 'Az modules are not found.  Installing the modules now. This may take a while...'
               Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -AllowClobber -Force -SkipPublisherCheck -PassThru
          } 
          else {
               Write-Output 'Az modules are found...'
          }
     }
}

# installs powershell 7 accordingly to your OS environment.
function Install-Powershell() {

     if (($PSVersionTable.OS) -match 'Microsoft Windows') {

          if ($true -eq (Test-Path 'HKLM:\SOFTWARE\Microsoft\PowerShellCore')) {
               Write-Host 'The installation of Powershell 7 is not found on your machine. This will be installed...'
               Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -EnablePSRemoting -AddExplorerContextMenu"
               Write-Host 'Powershell 7 is now installed on your machine.  Please CLOSE and REOPEN the current PowerShell window, then run the script again.'
         } 
         else { Write-Host 'Powershell 7 is found on your system.  You are all good!' }
     }
     elseif (($PSVersionTable.OS) -match 'Darwin') {

          Write-Host 'MacOS detected... continuing with bash script to install Brew and PowerShell...'
          '#!/usr/bin/env sh' | Out-File  $datapath/$temppath/$sh_filename -Force
          '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"' | Out-File $datapath/$temppath/$sh_filename -Append
          'brew install --cask powershell' | Out-File $datapath/$temppath/$sh_filename -Append
          & bash "$datapath/$temppath/$sh_filename"
     }
     else { Write-Host 'You seem to running neither Windows or MacOS...' }
}

# prepares for temporary script location.
function Set-FolderPath() {

     if (!(Test-Path -Path $datapath/$temppath)) { 
          New-Item $datapath/$temppath -ItemType Directory | Format-Table
     } else {
          Remove-Item $datapath -Recurse -Force
          New-Item $datapath/$temppath -ItemType Directory | Format-Table
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
     } else { Write-host 'The legacy AzureRM is not found on your system.'}
}

# aggregate all fuction calls.
function Set-PSEnvironment() {
     Set-FolderPath
     Install-Powershell         
     Install-AzModules
     Remove-AzureRM
}

Set-PSEnvironment
