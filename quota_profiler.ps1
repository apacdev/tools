# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
# ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
# PARTICULAR PURPOSE.
# CUSTOMER SUCCESS UNIT, MICROSOFT CORP. APAC.

Clear-Host

function Get-PSEnvironmentValidation() {
    # check for OS environment
    if ($PSVersionTable.OS -match 'Microsoft Windows') {
        # if on Windows, easiest way to check PS7 installation is to peek into Windows Registry.
        Write-Host 'OS: Windows'
        return ($true -eq (Test-Path 'HKLM:\SOFTWARE\Microsoft\PowerShellCore')) ? $true : $false
    }
    elseif ($PSVersionTable.OS -match 'Darwin') {
        # if non-Windows is detected, the script continues even there is no PS7 detected, and you may encounter an error (work-in-progress).
        # on MacOS, there is no easy way to check if it has the latest PS is installed.
        Write-Host 'OS: MacOS'
        return ( -not [int] ($PSVersionTable.PSVersion.Major.ToString() + $PSVersionTable.PSVersion.Minor.ToString()) -lt 7.0) ? $true : $false
    } 
    else {
        Write-Host 'OS: Linux or Unix'
        Write-Host 'Work-in-progress for other OS environment...'
    }
}

############################################################################## 
# main (PowerShell 7 indded as tenary operator is used)
##############################################################################

# ensure that the right version of powershell is ready on the system (it works properly only on Windows now).
if (-not (Get-PSEnvironmentValidation)) {
    Write-Host 'PowerShell 7 is not found on your system.  Please refer to the README of this repository and run Prerequisite section to set your running environment first (https://github.com/ms-apac-csu/tools).'
    break;
}

 If ($null -eq (Get-InstalledModule -Name Az -ErrorAction SilentlyContinue)) {
    Write-Host 'No Az modules are found on your machine.  Please refer to the README of this repository and run Prerequisite section to set your running environment first (https://github.com/ms-apac-csu/tools).'
    break;
} 
else {
    Write-Host 'Az modules are found on your machine.  The quota priling will resume.'
}

Clear-AzContext -Force -ErrorAction SilentlyContinue
Connect-AzAccount -WarningAction SilentlyContinue | Out-Null # use -UseDeviceAuthentication option for Device Authentication for MFA. 

# path to the outfile (csv) - if you are to use "relative location (e.g. c:\users\{your folder}\)"
$datapath = "./quotautil"
$temppath = "$datapath/temp"
$merged_filename = "all_subscriptions.csv"

# retrives list of subscripotions and regions (where resources are deployed in).
if ($null -eq ($subscriptions = Get-AzSubscription -ErrorAction SilentlyContinue)) {
    Write-Output "There seems to be no subscriptions your Azure account. Nothing to process!"
    break;
}

if ($null -eq ($locations =(Get-AzResource | ForEach-Object {$_.Location} | Sort-Object |  Get-Unique ))) {
    Write-Output "There seems to be no resources deployed in your Azure account. Nothing to process!"
    break;
}

# keeps the date-time of when script ran.
$datetime = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm')

# see if the data path exists and create one if not.
if (!(Test-Path -Path $datapath/temp)) { 
    New-Item $datapath/temp -ItemType Directory
}

# delete merged csv file to ensure no data are appended to old ones.
if (Test-Path -Path $datapath\$merged_filename -PathType Leaf) {
    Remove-Item -Path $datapath\$merged_filename -Force
}

# initialize temporary variables...
$objectarray = @()
$allsubscriptions = @()

Write-Output "`n===== There are $($subscriptions.Count) subscription(s) ======`n"

# loops through subscription list
foreach($subscription in $subscriptions) {

    # may not needed but just to make sure that the resource provider is regigered in the subscriptions.
    Register-AzResourceProvider -ProviderNamespace Microsoft.Capacity -ConsentToPermissions $true -ErrorAction SilentlyContinue | Out-Null

    # set the context from the current subscription
    Set-AzContext -Subscription $subscription | Out-Null
    $currentAzContext = Get-AzContext
    
    # loops through locations where the resources are deployed in
    foreach ($location in $locations) {

        Write-Output "Currently fetching resource data in $location / $subscription"
        try {

            # Get a list of Compute resources under the current subscription context
            $vmQuotas = Get-AzVMUsage -Location $location -ErrorAction SilentlyContinue
            $networkQuotas = Get-AzNetworkUsage -Location $location -ErrorAction SilentlyContinue
            $storageQuotas = Get-AzStorageUsage -Location $location -ErrorAction SilentlyContinue

        } catch [System.SystemException] {

            Write-Host 'An error occurred while fetching the usage data from Azure. Please try again later. Exiting the current process.'
            Write-Host $_.ScriptStackTrace
            break;
        }
        
        # Get usage data of each Compute resources 
        foreach($vmQuota in $vmQuotas) {

            $usage  = ($vmQuota.Limit -gt 0) ? $($vmQuota.CurrentValue / $vmQuota.Limit) : 0
            $object = New-Object -TypeName PSCustomObject
            $object | Add-Member -Name 'datetime_in_utc' -MemberType NoteProperty -Value $datetime
            $object | Add-Member -Name 'subscription_name' -MemberType NoteProperty -Value "$($currentAzContext.Subscription.Name) ($($CurrentAzContext.Subscription.Id))"
            $object | Add-Member -Name 'resource_name' -MemberType NoteProperty -Value "$($vmQuota.Name.LocalizedValue)"
            $object | Add-Member -Name 'location' -MemberType NoteProperty -Value $location
            $object | Add-Member -Name 'current_value' -MemberType NoteProperty -Value $vmQuota.CurrentValue
            $object | Add-Member -Name 'limit' -MemberType NoteProperty -Value $vmQuota.Limit
            $object | Add-Member -Name 'usage' -MemberType NoteProperty -Value "$(([math]::Round($usage, 2) * 100).ToString())%"
            $objectarray += $object
        }

        # Get usage data of each network resources 
        foreach ($networkQuota in $networkQuotas) {

            $usage = ($networkQuota.Limit -gt 0) ? $($networkQuota.CurrentValue / $networkQuota.Limit) : 0
            $object = New-Object -TypeName PSCustomObject
            $object | Add-Member -Name 'datetime_in_utc' -MemberType NoteProperty -Value $datetime
            $object | Add-Member -Name 'subscription_name' -MemberType NoteProperty -Value "$($currentAzContext.Subscription.Name) ($($CurrentAzContext.Subscription.Id))"
            $object | Add-Member -Name 'resource_name' -MemberType NoteProperty -Value "$($networkQuota.Name.LocalizedValue)"
            $object | Add-Member -Name 'location' -MemberType NoteProperty -Value $location
            $object | Add-Member -Name 'current_value' -MemberType NoteProperty -Value $networkQuota.CurrentValue
            $object | Add-Member -Name 'limit' -MemberType NoteProperty -Value $networkQuota.Limit
            $object | Add-Member -Name 'usage' -MemberType NoteProperty -Value "$(([math]::Round($usage, 2) * 100).ToString())%"
            $objectarray += $object
        }

        # Get usage data of each network resources 
        foreach ($storageQuota in $storageQuotas) {

            $usage = ($storageQuotas.Limit -gt 0) ? $($storageQuotas.CurrentValue / $storageQuotas.Limit) : 0
            $object = New-Object -TypeName PSCustomObject
            $object | Add-Member -Name 'datetime_in_utc' -MemberType NoteProperty -Value $datetime
            $object | Add-Member -Name 'subscription_name' -MemberType NoteProperty -Value "$($currentAzContext.Subscription.Name) ($($CurrentAzContext.Subscription.Id))"
            $object | Add-Member -Name 'resource_name' -MemberType NoteProperty -Value "$($storageQuota.Name.LocalizedValue)"
            $object | Add-Member -Name 'location' -MemberType NoteProperty -Value $location
            $object | Add-Member -Name 'current_value' -MemberType NoteProperty -Value $storageQuota.CurrentValue
            $object | Add-Member -Name 'limit' -MemberType NoteProperty -Value $storageQuota.Limit
            $object | Add-Member -Name 'usage' -MemberType NoteProperty -Value "$(([math]::Round($usage, 2) * 100).ToString())%"
            $objectarray += $object
        }
    }

    # saves outputs into .csv file
    $filename = $($currentAzContext.Subscription.Id)+".csv"
    $objectarray | Export-Csv -Path $("$datapath/temp/$filename") -NoTypeInformation
    $allsubscriptions += $objectarray
    $objectarray = @()
}

# process the consolidated objects to a .csv file
$allsubscriptions | Export-Csv -Path $datapath/$merged_filename
$allsubscriptions = @()

# zip the output files and tidy up the temp folder
Compress-Archive -Path "$temppath/*.csv" -CompressionLevel "Fastest" -DestinationPath "$datapath/quotautil.zip" -Force
Remove-Item -Path "$temppath/" -Recurse -Force

# now the job is done...!
Write-Output "`n===== Profiling completed =====" 
Get-ChildItem -Path $datapath
