#Modify Azure IaaS V1 Vnet with Public address of the local network gateway in ADATUM-BRANCH-VNET
#Note ereplace the 1.1.1.1 with Public address of the local network gateway in NetworkConfig.txt file.
Add-AzureAccount

Get-AzureSubscription

Select-AzureSubscription -SubscriptionName 'Developer Program Benefit'

$netconfigpath = Join-Path $pwd  "NetworkConfig.txt"

Set-AzureVNetConfig -ConfigurationPath $netconfigpath 

Set-AzureVNetGatewayKey -VnetName Adatum-Branch-Vnet -LocalNetworkSiteName  HQ -SharedKey 12345