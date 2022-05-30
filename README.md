# tools

[DESCRIPTION]

The script retrieves quota usage vs. approaved across all subscriptions under your Azure tenant.  It generates two output file: 1) all_subscriptions.csv, and 2) quotautil.zip.  The first includes quota information of all subscriptions and regions in a single file while the second one has csv files from each subscriptions in a zip format.

[PREREQUISITE]

The script is tested on PowerShell 7.0 with Az Modules installed.  It's a quick and dirty way to check the running envinroment and setup.  1) Go to Run (Win + R) and enter "cmd.exe".  2) At the command prompt, copy and paste the below powershell command to run (you do not need Admin right). Note: You may need to **run this again after PowerShell 7.0 is installed** for the script to continue setting up of Az Modules.

    powershell -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/Set-PSEnvironment.ps1'))"
    
[USAGE]

Once your running environment is ready (refer to the Prerequisite section above), simply fetch this quota_profiler.ps1 to your local drive and run it in your powershell (pwsh).  You can also run the script directly from this repo by running the following command at your Command Line prompt.  1) Go to Run (Win + R) and enter "cmd.exe".  2) At the command prompt, copy and paste the below pwsh command to run (you do not need Admin right).

    pwsh -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ms-apac-csu/tools/main/quota_profiler.ps1'))"
