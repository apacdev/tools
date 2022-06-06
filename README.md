# tools

## DESCRIPTION

The script retrieves quota usage vs. approved across all subscriptions under your Azure tenant.
It generates two output files:

- all_subscriptions.csv - includes quota information of all subscriptions and regions in a single file
- quotautil.zip - csv files from each subscriptions in a zip format

## PREREQUISITE

**Internet connectivity**
Your PC must be connected to the Internet (direct or via proxy) to download the script and required packages

**For Windows Users**:
Go to Run (Win + R) and enter "cmd.exe". At the command prompt, run the PowerShell command below (you do not need Admin right).

    powershell -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"

**For Ubuntu (20.04 LTS) and MacOS Users**:
Please follow the instructions below to install Homebrew, PowerShell, and other Pre-requisites on your system.

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ms-apac-csu/tools/main/pre-requisites.sh)"

    NOTE: you will need sudo access to install packages.

## USAGE

Once your running environment is ready (refer to the Prerequisite section above), At the command prompt(cmd.exe for windows and bash for linux) copy and paste the below pwsh command to run (you do not need Admin rights).

    pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Get-AzQuotaUtil.ps1'))"

As an alternative, you can also fetch this quota_profiler.ps1 to your local drive and run the script with your PowerShell 7 (pwsh) or Command Line (cmd.exe).
