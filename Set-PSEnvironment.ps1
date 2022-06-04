
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
# ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
# PARTICULAR PURPOSE.
# CUSTOMER SUCCESS UNIT, MICROSOFT CORP. APAC.

##########################################################################################
# a quick and dirty way to check and setup running environment.
##########################################################################################

function IsPowerShell7() 
{
    if (Test-Path 'HKLM:\SOFTWARE\Microsoft\PowerShellCore') 
    { 
        return $true
    } 
    else
    { 
        Write-Host 'No PowerShell 7+ is found on your system.'
        return $false 
    }
}

function IsWindows() 
{
    if (([System.Environment]::OSVersion.Platform) -match 'Win32NT') 
    { 
        return $true 
    } 
    else 
    { 
        return $false 
    }
}

function IsAzModulesFound() 
{
    If (-not ($null) -eq (Get-InstalledModule -Name Az -ErrorAction SilentlyContinue))
    { 
        return $true 
    } 
    else 
    { 
        return $false 
    }
}

function IsAzureRmModulesFound() 
{
    if ($null -ne (Get-InstalledModule -Name AzureRm -ErrorAction SilentlyContinue)) 
    { 
        return $true 
    } 
    else
    {
        return $false 
    }
}

function Install-AzModules()
{
    Write-Host 'Installing Az Modules on your OS now. It may take a while...'
    if (IsWindows)
    {
        if (IsPowerShell7) 
        {
            Start-Process pwsh.exe '-c', { 
                If ($null -eq (Get-InstalledModule -Name Az -ErrorAction SilentlyContinue))
                {
                    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
                    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -AllowClobber -Force -SkipPublisherCheck -PassThru 
                }
            } -Wait            
        }
    }
    else
    {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -AllowClobber -Force -SkipPublisherCheck -PassThru
    }
}

function Install-PowerShell7()
{
    Write-Host 'Installing the latest PowerShell on your system.'
    try 
    {
        if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
        {
            Invoke-Expression  "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -Quiet -AddExplorerContextMenu  -EnablePSRemoting"
        }
        else
        {
            Invoke-Expression  "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -AddExplorerContextMenu  -EnablePSRemoting"
        }
    } 
    catch
    {
        Write-Host 'An error occurred during pulling the data from the remote server.  Please try again later...'
    }
}

function Uninstall-AzureRmModules() 
{
    Write-Host "Uninstalling AzureRm Modules (from PowerShell Core only). This will take a while..."
    if (IsWindows)
    {
        if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
        {
            Uninstall-AzureRm -PassThru; Write-Host 'The legacy AzureRm Modules are removed from your system.'
        }
        else
        {
            Invoke-Command -ScriptBlock { Start-Process pwsh.exe '-c', { Uninstall-AzureRm -PassThru; Write-Host 'The legacy AzureRM Modules are removed from your system.'} -Verb RunAs -Wait }
        }
    }
    else
    {
        Uninstall-AzureRm -PassThru; Write-Host 'The legacy AzureRM Modules are removed from your system.'
    }
}

function Set-PSEnvironment()
{
    if (IsWindows) 
    {
        if (-not (IsPowerShell7))    { Install-PowerShell7      } 
        if (-not (IsAzModulesFound)) { Install-AzModules        }
        if (IsAzureRmModulesFound)   { Uninstall-AzureRmModules }
    } 
    else 
    {
        if (-not (IsAzModulesFound)) { Install-AzModules        }
        if (IsAzureRmModulesFound)   { Uninstall-AzureRmModules }
    }
}

Clear-Host

Set-PSEnvironment

function Get-PSEnvironment()
{
    if (IsWindows) 
    {
        if ((IsPowerShell7))                { '[OK] PowerShell 7+ is found on your system.'           ; return $true } 
        if ((IsAzModulesFound))             { '[OK] Az Modules are found on your system.'             ; return $true }
        if (-not (IsAzureRmModulesFound))   { '[OK] No conflict with AzureRm is found on your system.'; return $true }
    } 
    else 
    {
        if ((IsAzModulesFound))             { '[OK] Az Modules are found on your system.'             ; return $true }
        if (-not (IsAzureRmModulesFound))   { '[OK] No conflict with AzureRm is found on your system.'; return $true }
    }

    return $false
}

if (Get-PSEnvironment) 
{
    Write-Host 'Your setting meets the Prerequisites.  Please proceed with running the Get-AzQuotaUtil.ps1 script as described in Usage section in README.'
}
else
{
    Write-Host 'Your seetings do not seem to meet the Rerequisites!'
}
