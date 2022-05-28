# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
# ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
# PARTICULAR PURPOSE.
# Author: Patrick Shim (pashim@microsoft.com)

############################################################################## 
# a helper function to setup running environment for the script (windows only)
##############################################################################

function Set-PSEnvironment {

    if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {

        if ([int]$PSVersionTable.PSVersion.Major -lt 7) {

            Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -EnablePSRemoting -AddExplorerContextMenu"
            
            if ($null -ne (Get-InstalledModule -Name "AzureRm.Profile" -ErrorAction SilentlyContinue)) {
                Uninstall-AzureRm
            }
            if ($null -eq (Get-InstalledModule -Name "Az" -ErrorAction SilentlyContinue)) {
                Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
            }
        }
    }

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
}

############################################################################## 
# main
##############################################################################

Set-PSEnvironment
Clear-Host
Clear-AzContext -Force
Connect-AzAccount | Out-Null # -UseDeviceAuthentication # <= Uncomment this to use Device Authentication for MFA.

# path to the outfile (csv) - if you are to use "relative location (e.g. c:\users\{your folder}\)"
$datapath = "./quotautil"
$temppath = "$datapath/temp"
$merged_filename = "all_subscriptions.csv"

# see if the data path exists and create one if not.
if (!(Test-Path -Path $datapath/temp)) { 
    New-Item $datapath/temp -ItemType Directory
}

# delete merged csv file to ensure no data are appended to old ones.
if (Test-Path -Path $datapath\$merged_filename -PathType Leaf) {
    Remove-Item -Path $datapath\$merged_filename -Force
}

# retrives region list across the resources, and pull all the subscriptions in the tenant.
$locations = Get-AzResource | ForEach-Object {$_.Location} | Sort-Object |  Get-Unique
$subscriptions = Get-AzSubscription
$datetime = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm')
$objectarray = @()
$allsubscriptions = @()

Write-Output "`n===== There are $($subscriptions.Count) subscription(s) ======`n"

# loops through subscription list
foreach($subscription in $subscriptions) {

    # set the context from the current subscription
    Set-AzContext -Subscription $subscription | Out-Null
    $currentAzContext = Get-AzContext

    # loops through locations where the resources are deployed in
    foreach ($location in $locations) {

        Write-Output "Currently fetching resource data in $location / $subscription"

        # Get a list of Compute resources under the current subscription context
        $vmQuotas = Get-AzVMUsage -Location $location -ErrorAction SilentlyContinue
        $networkQuotas = Get-AzNetworkUsage -Location $location -ErrorAction SilentlyContinue
        $storageQuotas = Get-AzStorageUsage -Location $location -ErrorAction SilentlyContinue
        
        # Get usage data of each Compute resources 
        foreach($vmQuota in $vmQuotas) {

            $usage = if($vmQuota.Limit -gt 0) {$($vmQuota.CurrentValue / $vmQuota.Limit)} else {0}
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

            $usage = if($networkQuota.Limit -gt 0) {$($networkQuota.CurrentValue / $networkQuota.Limit)} else {0}
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

            $usage = if($storageQuotas.Limit -gt 0) {$($storageQuotas.CurrentValue / $storageQuotas.Limit)} else {0}
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
    $allsubscriptions += $array
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
