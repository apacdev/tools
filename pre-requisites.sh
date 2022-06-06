# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
# ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
# PARTICULAR PURPOSE.
# CUSTOMER SUCCESS UNIT, MICROSOFT CORP. APAC.

#!/bin/bash

clear
OS="$(uname)"

if [ $OS == "Darwin" ]; then
    if [ -z "$(which pwsh)" ]; then 
        echo '[INFO] No valid PowerShell is found on your system. It will be installed.'
        if [ -z "$(which brew)" ]; then
            echo '[INFO] Homebrew is not installed on your system.  It is required to install PowerShell.' 
            echo '[INFO] Installing Homebrew now...'
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            echo '[INFO] Installing PowerShell now...'
            brew install --cask powershell
            pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"
        else
            echo '[ OK ] HomeBrew is installed on your system.'
            echo '[INFO] Installing PowerShell now...'
            brew install --cask powershell
            pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"
        fi
    else
        echo '[ OK ] Valid owerShell is found on your system.'
        pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"
    fi
elif [ $OS == "Linux" ]; then
    if [ -z "$(which pwsh)" ]; then
        echo '[ NO ] No valid PowerShell is found on your system.'
        sudo apt-get update
        sudo apt-get install -y wget apt-transport-https software-properties-common
        wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
        sudo dpkg -i packages-microsoft-prod.deb
        sudo apt-get update
        sudo apt-get install -y powershell
        pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"
    else 
        echo '[ OK ] Valid Powershell is found on your system.'
        pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"
    fi
else
    echo '[ NO ] No known OS is found on your system.  This script only supports MacOS or Linux (Ubuntu).'
fi
