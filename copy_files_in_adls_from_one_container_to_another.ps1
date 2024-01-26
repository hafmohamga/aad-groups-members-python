# Source variables
$sourceSubId = "<source-subscription-id>" 
$sourceRG = "<source-resource-group>"
$sourceAccount = "<source-storage-account>"
$sourceContainer = "<source-container>"
$sourcePath = "<source-folder-path>"

# Destination variables 
$destSubId = "<dest-subscription-id>"
$destRG = "<dest-resource-group>" 
$destAccount = "<dest-storage-account>"
$destContainer = "<dest-container>"
$destPath = "<dest-folder-path>"

# Authenticate to both subscriptions
Connect-AzAccount
Set-AzContext -Subscription $sourceSubId
$sourceContext = Get-AzStorageAccount -ResourceGroupName $sourceRG -Name $sourceAccount

Set-AzContext -Subscription $destSubId
$destContext = Get-AzStorageAccount -ResourceGroupName $destRG -Name $destAccount 

# Copy folder recursively 
Get-AzDataLakeGen2ChildItem -Context $sourceContext -FileSystem $sourceContainer -Path $sourcePath | 
    Copy-AzDataLakeGen2Item -Context $destContext -DestFileSystem $destContainer -DestPath $destPath -Recurse

##########################################################################################################################################

# Set source variables
$sourceAccountName = "<source-account-name>"  
$sourceContainer = "<source-container>"
$sourceSAS= New-AzStorageContainerSASToken -Name $sourceContainer -Context $sourceCtx -Permission r -ExpiryTime (Get-Date).AddHours(2)
$sourcePath = "<path-to-copy-from>"

# Set destination variables
$destAccountName = "<dest-account-name>" 
$destContainer = "<dest-container>"
$destSAS= New-AzStorageContainerSASToken -Name $destContainer -Permission rw -ExpiryTime (Get-Date).AddHours(2) -Context $destCtx
$destPath = "<path-to-copy-to>"

# Construct source and dest URIs
$sourceUri = $sourceAccountName + ".dfs.core.windows.net/" + $sourceContainer + $sourceSAS
$destUri = $destAccountName + ".dfs.core.windows.net/" + $destContainer + $destSAS

# Perform copy
azcopy copy $sourceUri/$sourcePath $destUri/$destPath --recursive=true
