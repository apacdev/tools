# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
# ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
# PARTICULAR PURPOSE.
# Author: Patrick Shim (pashim@microsoft.com)

Clear-AzContext -Force
Connect-AzAccount # -UseDeviceAuthentication # <= Uncomment this to use Device Authentication for MFA.

$datetime = [System.DateTime]::UtcNow

# path to the outfile (csv) - if you are to use "relative location (e.g. c:\users\{your folder}\)"
$datapath = "./QuotaUtil"

# path to the outfile (csv) - if you are to use "absolute location"
#$datapath = "c:/temp/QuotaUtil"

if (!(Test-Path -Path $datapath/temp))
{ 
    New-Item $datapath/temp -ItemType Directory
}

# delete merged csv file to ensure no date is appended to old ones.
if (Test-Path -Path $datapath\all_subscriptions.csv -PathType Leaf)
{
    Remove-Item -Path $datapath\all_subscriptions.csv -Force
}

# retrives region list across the resources, and pull all the subscriptions in the tenant.
$locations = Get-AzResource | ForEach-Object {$_.Location} | Sort-Object |  Get-Unique

$subscriptions = Get-AzSubscription

$json = ''

# loops through subscription list
foreach($subscription in $subscriptions)
{
    Write-Output "Currently fetching resource data from $subscription"
    
    # set the context from the current subscription
    Set-AzContext -Subscription $subscription
    $currentAzContext = Get-AzContext

    # Get VM Quota and Utilization
    foreach ($location in $locations)
    {
        # Get a list of Compute resources under the current subscription context
        $vmQuotas = Get-AzVMUsage -Location $location -ErrorAction SilentlyContinue

        # Get usage data of each Compute resources 
        foreach($vmQuota in $vmQuotas)
        {
            $usage = 0
            if ($vmQuota.Limit -gt 0)
            {
                $usage = $vmQuota.CurrentValue / $vmQuota.Limit
            }
            $json += @"
            { 
                "Date Time (UTC)":"$datetime",
                "SubscriptionName":"$($currentAzContext.Subscription.Name) ($($CurrentAzContext.Subscription.Id))",
                "Name":"$($vmQuota.Name.LocalizedValue)", 
                "Category":"Compute", 
                "Location":"$location", 
                "CurrentValue":$($vmQuota.CurrentValue), 
                "Limit":$($vmQuota.Limit),
                "Usage":"$(([math]::Round($usage, 2) * 100).ToString())%"
            },
"@
        }
    }

    # Get Network Quota and its utilization
    foreach ($location in $locations)
    {
        $networkQuotas = Get-AzNetworkUsage -Location $location -ErrorAction SilentlyContinue
        foreach ($networkQuota in $networkQuotas)
        {
            $usage = 0

            if ($networkQuota.limit -gt 0)
            {
                $usage = $networkQuota.currentValue / $networkQuota.limit
            }

            $json += @"
            { 
                "Date Time (UTC)":"$datetime",
                "SubscriptionName":"$($currentAzContext.Subscription.Name) ($($CurrentAzContext.Subscription.Id))",
                "Name":"$($networkQuota.name.localizedValue)", 
                "Category":"Network",
                "Location":"$location", 
                "CurrentValue":$($networkQuota.currentValue), 
                "Limit":$($networkQuota.limit),
                "Usage":"$(([math]::Round($usage, 2) * 100).ToString())%"
            },
"@
        }
    }
    
    # Get Storage Quota and its utilization
    $storageQuota = Get-AzStorageUsage -Location $location -ErrorAction SilentlyContinue
    $usage = 0
    
    if ($storageQuota.Limit -gt 0)
    {
        $usage = $storageQuota.CurrentValue / $storageQuota.Limit
    }
    
    $json += @"
    { 
        "Date Time (UTC)":"$datetime",
        "SubscriptionName":"$($currentAzContext.Subscription.Name) ($($CurrentAzContext.Subscription.Id))",
        "Name":"$($storageQuota.LocalizedName)", 
        "Location":"$location", 
        "Category":"Storage", 
        "CurrentValue":$($storageQuota.CurrentValue), 
        "Limit":$($storageQuota.Limit),
        "Usage":"$(([math]::Round($usage, 2) * 100).ToString())%" 
    }
"@
    
    # Wrap in an array
    $json = "[$json]"
    $jsonObjects = $json | ConvertFrom-Json
    $json = ''
    $filename = $($currentAzContext.Subscription.Id)+".csv"
    $jsonObjects | Export-Csv -Path $("$datapath/temp/$filename") -NoTypeInformation
}

$compress = @{
    Path = "$datapath/temp/*.csv"
    CompressionLevel = "Fastest"
    DestinationPath = "$datapath/quotautil.zip"
  }

$csvContent = Get-Content "$datapath/temp/*.csv"

#Just a monkey way to remove repeated column headers from each csv files... Anyone with better idea?
$index = 0

foreach ($line in $csvContent)
{
    if ($index -lt 1)
    {
        $line | Add-Content "$datapath/all_subscriptions.csv"
    
    }
    else
    {
        if (($line -notlike "*Date Time (UTC)*"))
        {
            $line | Add-Content "$datapath/all_subscriptions.csv"
        }
     }
    $index += 1
 }

# zip up the individual files and clean up the temp files.
Compress-Archive @compress -Force
Remove-Item -Path "$datapath/temp/*" -Include *.csv

Write-Output "`nProfiling completed." | Format-Table
Get-ChildItem -Path $datapath
