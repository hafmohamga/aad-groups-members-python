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
