#Modify Azure IaaS V1 Vnet 
Add-AzureAccount

Get-AzureSubscription

Select-AzureSubscription -SubscriptionName 'Developer Program Benefit'

$netconfigpath = Join-Path $pwd  "NetworkConfig.txt"

Set-AzureVNetConfig -ConfigurationPath $netconfigpath 
