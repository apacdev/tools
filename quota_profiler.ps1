# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
# ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
# PARTICULAR PURPOSE.
# Author: Patrick Shim (pashim@microsoft.com)

Clear-AzContext -Force
Clear-Host
Connect-AzAccount | Out-Null # -UseDeviceAuthentication # <= Uncomment this to use Device Authentication for MFA.

# path to the outfile (csv) - if you are to use "relative location (e.g. c:\users\{your folder}\)"
$datapath = "./QuotaUtil"

# path to the outfile (csv) - if you are to use "absolute location"
#$datapath = "c:/temp/QuotaUtil"

# see if the data path exists and create one if not.
if (!(Test-Path -Path $datapath/temp)) { 
    New-Item $datapath/temp -ItemType Directory
}

# delete merged csv file to ensure no data are appended to old ones.
if (Test-Path -Path $datapath\all_subscriptions.csv -PathType Leaf) {
    Remove-Item -Path $datapath\all_subscriptions.csv -Force
}

# retrives region list across the resources, and pull all the subscriptions in the tenant.
$locations = Get-AzResource | ForEach-Object {$_.Location} | Sort-Object |  Get-Unique
$subscriptions = Get-AzSubscription
$datetime = [System.DateTime]::UtcNow
$array = @()

Write-Output "`n===== There are $($subscriptions.Count) subscription(s) ======`n"

# loops through subscription list
foreach($subscription in $subscriptions) {

    Write-Output "Currently fetching resource data from $subscription"
    
    # set the context from the current subscription
    Set-AzContext -Subscription $subscription | Out-Null
    $currentAzContext = Get-AzContext

    # Get VM Quota and Utilization
    foreach ($location in $locations) {
        # Get a list of Compute resources under the current subscription context
        $vmQuotas = Get-AzVMUsage -Location $location -ErrorAction SilentlyContinue
        $networkQuotas = Get-AzNetworkUsage -Location $location -ErrorAction SilentlyContinue
        $storageQuotas = Get-AzStorageUsage -Location $location -ErrorAction SilentlyContinue
    
        # Get usage data of each Compute resources 
        foreach($vmQuota in $vmQuotas) {

            $usage = ($vmQuota.Limit -gt 0) ? $($vmQuota.CurrentValue / $vmQuota.Limit) : 0
            $object = New-Object -TypeName PSCustomObject
            $object | Add-Member -Name 'datetime_in_utc' -MemberType NoteProperty -Value $datetime
            $object | Add-Member -Name 'subscription_name' -MemberType NoteProperty -Value "$($currentAzContext.Subscription.Name) ($($CurrentAzContext.Subscription.Id))"
            $object | Add-Member -Name 'resource_name' -MemberType NoteProperty -Value "$($vmQuota.Name.LocalizedValue)"
            $object | Add-Member -Name 'location' -MemberType NoteProperty -Value $location
            $object | Add-Member -Name 'current_value' -MemberType NoteProperty -Value $vmQuota.CurrentValue
            $object | Add-Member -Name 'limit' -MemberType NoteProperty -Value $vmQuota.Limit
            $object | Add-Member -Name 'usage' -MemberType NoteProperty -Value "$(([math]::Round($usage, 2) * 100).ToString())%"
            $array += $object
        }
   
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
            $array += $object
        }
   
        foreach ($storageQuota in $storageQuotas) {
            # Get Storage Quota and its utilization
            $usage = ($storageQuota.Limit -gt 0) ? $($storageQuota.CurrentValue / $storageQuota.Limit) : 0
            $object = New-Object -TypeName PSCustomObject
            $object | Add-Member -Name 'datetime_in_utc' -MemberType NoteProperty -Value $datetime
            $object | Add-Member -Name 'subscription_name' -MemberType NoteProperty -Value "$($currentAzContext.Subscription.Name) ($($CurrentAzContext.Subscription.Id))"
            $object | Add-Member -Name 'resource_name' -MemberType NoteProperty -Value "$($storageQuota.Name.LocalizedValue)"
            $object | Add-Member -Name 'location' -MemberType NoteProperty -Value $location
            $object | Add-Member -Name 'current_value' -MemberType NoteProperty -Value $storageQuota.CurrentValue
            $object | Add-Member -Name 'limit' -MemberType NoteProperty -Value $storageQuota.Limit
            $object | Add-Member -Name 'usage' -MemberType NoteProperty -Value "$(([math]::Round($usage, 2) * 100).ToString())%"
            $array += $object
        }
        
    # saves outputs into .csv file
    $filename = $($currentAzContext.Subscription.Id)+".csv"
    $array | Export-Csv -Path $("$datapath/temp/$filename") -NoTypeInformation
    $array = @()
}

$compress = @{
    Path = "$datapath/temp/*.csv"
    CompressionLevel = "Fastest"
    DestinationPath = "$datapath/quotautil.zip"
}

# reads in all .csv file for further processing (zipping, removeing duplicated column headers, etc.)
$csvContent = Get-Content "$datapath/temp/*.csv"

#Just a monkey way to remove repeated column headers from each csv files... Anyone with better idea?
$index = 0
Write-Output "`n===== Finalizing the output files... =====" 

foreach ($line in $csvContent) {

    if ($index++ -lt 1) {
        #leave the first column header alone
        $line | Add-Content "$datapath/all_subscriptions.csv"
    }
    else { 
        # remove duplicated column headers for the rest
        if (($line -notlike "*Date Time (UTC)*")) { 
            $line | Add-Content "$datapath/all_subscriptions.csv" 
        }
     }
 }

# zip up the individual files and clean up the temp files.
Compress-Archive @compress -Force
Remove-Item -Path "$datapath/temp/" -Recurse -Force
Write-Output "`n===== Profiling completed =====" 
Get-ChildItem -Path $datapath
