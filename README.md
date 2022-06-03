# tools

[DESCRIPTION]

The script retrieves quota usage vs. approved across all subscriptions under your Azure tenant.  It generates two output files: 1) all_subscriptions.csv, and 2) quotautil.zip.  The first includes quota information of all subscriptions and regions in a single file while the second one has csv files from each subscriptions in a zip format.

[PREREQUISITE]

**For Windows Users**:
1) Go to Run (Win + R) and enter "cmd.exe".  2) At the command prompt, run the PowerShell command below (you do not need Admin right). Note: You need to **run this again after PowerShell 7.0 is installed** for the script to continue with Pre-requisites.

    powershell -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"

**For MacOS Users**:
Please follow the instructions below to install Homebrew, PowerShell, and other Pre-requisites on your system.

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install --cask powershell
    pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"

**For Linux (Ubuntu) Users**:
Please follow the instructions below to install PowerShell and Pre-requisites on your system.

    sudo apt-get update
    sudo apt-get install -y wget apt-transport-https software-properties-common
    wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
    sudo dpkg -i packages-microsoft-prod.deb
    sudo apt-get update
    sudo apt-get install -y powershell
    pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"
        
[USAGE]

Once your running environment is ready (refer to the Prerequisite section above), simply run the script directly from this repo by running the following command at your Command Line prompt.  1) Go to Run (Win + R) and enter "cmd.exe".  2) At the command prompt, copy and paste the below pwsh command to run (you do not need Admin rights).

    pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/quota_profiler.ps1'))"

As an alternative, you can also fetch this quota_profiler.ps1 to your local drive and run the script with your PowerShell 7 (pwsh) or Command Line (cmd.exe). 
