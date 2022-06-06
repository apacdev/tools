# tools

[DESCRIPTION]

The script retrieves quota usage vs. approved across all subscriptions under your Azure tenant.  It generates two output files: 1) all_subscriptions.csv, and 2) quotautil.zip.  The first includes quota information of all subscriptions and regions in a single file while the second one has csv files from each subscriptions in a zip format.

[PREREQUISITE]

**For Windows Users**:
Go to Run (Win + R) and enter "cmd.exe". At the command prompt, run the PowerShell command below (you do not need Admin right).

    powershell -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"

**For Ubuntu (20.04 LTS) and MacOS Users**:
Please follow the instructions below to install Homebrew, PowerShell, and other Pre-requisites on your system.

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ms-apac-csu/tools/main/pre-requisites.sh)"
        
[USAGE]

Once your running environment is ready (refer to the Prerequisite section above), simply run the script directly from this repo by running the following command at your Command Line prompt.  1) Go to Run (Win + R) and enter "cmd.exe".  2) At the command prompt, copy and paste the below pwsh command to run (you do not need Admin rights).

    pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Get-AzQuotaUtil.ps1'))"

As an alternative, you can also fetch this quota_profiler.ps1 to your local drive and run the script with your PowerShell 7 (pwsh) or Command Line (cmd.exe). 
