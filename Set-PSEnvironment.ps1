
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
# ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
# PARTICULAR PURPOSE.
# CUSTOMER SUCCESS UNIT, MICROSOFT CORP. APAC.

##########################################################################################
# a quick and dirty way to check and setup running environment.
##########################################################################################

function Install-PowerShell() 
{
    if (Test-Path 'HKLM:\SOFTWARE\Microsoft\PowerShellCore')
    { 
        Write-Host 'Powershell 7+ is already installed on your Windows.' 
    } 
    else 
    {
        Write-Host 'Powershell 7+ is not found on your Windows. The installation will start...'    
        try 
        {
            # retrieves the latest powershell from the Microsoft repo.
            powershell -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"
        }
        catch 
        {
            # there was an error in calling REST. 
            Write-Host 'An error occurred during pulling the data from the remote server.  Please try again later...'
        }
    }  
}

# install az modules for powershell 7 if it does not exist on your machines.
function Install-AzModules() 
{
  pwsh -NoProfile -ExecutionPolicy ByPass -Command 
  {
    If ($null -eq (Get-InstalledModule -Name Az -ErrorAction SilentlyContinue))
    {
      Write-Host 'No Az Modules are found on your system.  They will be installed now. It may take a while...'
      Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -AllowClobber -Force -SkipPublisherCheck -PassThru
    } 
    else 
    { 
      Write-Output 'Az Modules are found...' 
    }
 }
}

# removes legacy AzureRM components to avoid conflicts with Az Modules.
function Remove-AzureRM() 
{
    if (-not $null -eq (Get-InstalledModule -Name AzureRM -ErrorAction SilentlyContinue))
    {
        Write-Host 'The legacy AzureRM Modules are found, and they will be removed. You need to give an administrator access if prompted.'
        if (([System.Environment]::OSVersion.Platform) -match 'Win32NT')
        {
            if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
            {
                Write-Host "Uninstalling AzureRm Modules. This will take a while..."
                Uninstall-AzureRM -PassThru
            } 
        }
        else 
        {
            Write-Host "Uninstalling AzureRm Modules. This will take a while..."
            Uninstall-AzureRM -PassThru
        }
     }
     else 
     {
        Write-host 'No legacy AzureRM Modules are found on your system (which means good!).'
     }
}

# aggregates all fuction calls.
function Set-PSEnvironment()
{
    Install-PowerShell
    Install-AzModules
    Remove-AzureRM
    Start-Process -Wait "cmd" -ArgumentList '/k', {
      powershell -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"
    }
    Write-Host 'The setup of Prerequisites is now completed.  Please proceed with running the Get-AzQuotaUtil.ps1 script as described in Usage section in README.'
}

if (([System.Environment]::OSVersion.Platform) -match 'Win32NT')
{
    Set-PSEnvironment
}
else 
{
    Write-Host 'This Pre-requisite script is written for Windows only.  For other OS like MacOS or Linux, please refer to "For MacOS or Linux Users" section of the README'
}
