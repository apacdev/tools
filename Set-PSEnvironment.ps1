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

function Install-Powershell() {

    if (([System.Environment]::OSVersion.Platform) -match 'Win32NT') {
    
        Write-Host 'Windows OS is found...'
    
        if ($true -eq (Test-Path 'HKLM:\SOFTWARE\Microsoft\PowerShellCore')) {
        
            Write-Host 'Powershell 7 is found on your Windows system...' 
        } 
        else {
            # time to install latest powershell 
            Write-Host 'The installation of Powershell 7 is not found on your machine. This will be installed...'
            
            try {
                # retrieves the latest powershell from the Microsoft repo.
                Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -EnablePSRemoting -AddExplorerContextMenu"
                Write-Host 'Please CLOSE and REOPEN the current CommandLine (or PowerShell) window, then run the script again if PowerShell 7.0 is successfully installed.'
                break;
            }
            catch {
                # seems to be there was an error in calling REST. 
                Write-Host 'An error occurred during pulling the data from the remote server.  Please try again later...'
            }
        }  
    }
    
    if (([System.Environment]::OSVersion.Platform) -match 'Unix') {
        # there is no easy way to check which OS the system has with powershell 5 or less.  below is the monkey way.
        Write-Host 'MacOS or Linux/Unix is found. PS5 is not supported either on MacOS or Linux/Unix, so it will just do a version check, then install latest powershell.'
    
        if([int] ($PSVersionTable.PSVersion.Major.ToString() + $PSVersionTable.PSVersion.Minor.ToString()) -ge 7.0) {
            # no nicer way to check the powershell version.
            Write-Host 'Powershell 7 is found on your OS (non-Windows)...' 
        } 
        else {
            # looking all good. let's just make sure 
            Write-Host ' > PowerShell 7 on your OS is detected... continuing with bash script to install Brew and update powershell to the latest...'
            Set-FolderPath
            '#!/usr/bin/env sh' | Out-File  $datapath/$temppath/$sh_filename -Force
            '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"' | Out-File $datapath/$temppath/$sh_filename -Append
            # powershell core (6+) is only available for MacOS actually.  this routine may not be needed. 
            'brew upgrade --cask powershell' | Out-File $datapath/$temppath/$sh_filename -Append
            & bash "$datapath/$temppath/$sh_filename"
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

# prepares for temporary script location.
function Set-FolderPath() {

     if (!(Test-Path -Path $datapath/$temppath)) { 
          New-Item $datapath/$temppath -ItemType Directory | Format-Table
     } 
     else {
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
     }
     else {
        Write-host 'The legacy AzureRM is not found on your system (which means good!).'
     }
}

# aggregate all fuction calls.
function Set-PSEnvironment() {

     Install-Powershell         
     Install-AzModules
     Remove-AzureRM
}

Set-PSEnvironment
