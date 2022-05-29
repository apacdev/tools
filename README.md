# tools

[DESCRIPTION]

The script retrieves quota usage vs. approaved across all subscriptions under your Azure tenant.  It generates two output file: 1) all_subscriptions.csv, and 2) quotautil.zip.  The first includes quota information of all subscriptions and regions in a single file while the second one has csv files from each subscriptions in a zip format.

[PREREQUISITE]

The script is tested on PowerShell 7.0 with Az Modules installed.  Run the following line in your powershell.  It's a quick and dirty way to check the running envinroment and setup.  You may need to run this again after PowerShell 7.0 is installed for the script to run the rest using 'pwsh'.

    powershell -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"

[USAGE]

Simply fetch this quota_profiler.ps1 to your local drive and run it in your powershell.  You can also run the script directly from this repo by running the following command at your powershell prompt: 

Go to Run (Win + R) then enter "cmd.exe."  At the command prompt, copy and paste the below pwsh command to run (you do not need Admin right).

    pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/quota_profiler.ps1'))"


