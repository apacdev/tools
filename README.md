# tools

[DESCRIPTION]
The script retrieves quota usage vs. approaved across all subscriptions under your Azure tenant.  It generates two output file: 1) all_subscriptions.csv, and 2) quotautil.zip.  The first includes quota information of all subscriptions and regions in a single file while the second one has csv files from each subscriptions in a zip format.

[PREREQUISITE]
The script is tested on PowerShell 7.0 with Az Modules installed.

[USAGE]
Simply fetch this quota_profiler.ps1 to your local drive and run it in your powershell.  You can also run the script directly from this repo by running the following command at your powershell prompt: 

powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/quota_profiler.ps1'))"


