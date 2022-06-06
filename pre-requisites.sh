#!/bin/bash
OS="$(uname)"

function cecho() {
    local exp=$1;
    local color=$2;
    
    if ! [[ $color =~ '^[0-9]$' ]] ; then
       case $(echo $color | tr '[:upper:]' '[:lower:]') in
        black) color=0 ;;
        red) color=1 ;;
        green) color=2 ;;
        yellow) color=3 ;;
        blue) color=4 ;;
        magenta) color=5 ;;
        cyan) color=6 ;;
        white|*) color=7 ;; # white or invalid color
       esac
    fi
    
    tput setaf $color;
    echo $exp;
    tput sgr0;
}

if [ $OS == "Darwin" ]; then
    if [ -z "$(which pwsh)" ]; then 
        cecho '[INFO] No valid PowerShell is found on your system. It will be installed.' blue
        if [ -z "$(which brew)" ]; then
            cecho '[ NO ] Homebrew is not installed on your system.  It is required to install PowerShell.' red
            cecho '[INFO] Installing Homebrew now...' blue
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            cecho '[INFO] Installing PowerShell now...' blue
            brew install --cask powershell
            cecho '[INFO] Installing other pre-requisites on your system now...' blue
            pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"
        else
            cecho '[ OK ] HomeBrew is installed on your system.' green
            cecho '[INFO] Installing PowerShell now...' blue
            brew install --cask powershell
            cecho '[INFO] Installing other pre-requisites on your system now...' blue
            pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"
        fi
    else
        cecho '[ OK ] Valid owerShell is found on your system.' green
        pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"
    fi
elif [ $OS == "Linux" ]; then
    if [ -z "$(which pwsh)" ]; then
        cecho '[ NO ] No valid PowerShell is found on your system.' red
        sudo apt-get update
        sudo apt-get install -y wget apt-transport-https software-properties-common
        wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
        sudo dpkg -i packages-microsoft-prod.deb
        sudo apt-get update
        cecho '[INFO] Installing PowerShell on your system now...' blue
        sudo apt-get install -y powershell
        cecho '[INFO] Installing other pre-requisites on your system now...' blue
        pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"
    else 
        cecho '[ OK ] Valid Powershell is found on your system.' green
        pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"
    fi
else
    cecho '[ NO ] No known OS is found on your system.  This script only supports MacOS or Linux (Ubuntu).' red
fi
