#Export Azure IaaS V1 Vnet Configuration
Add-AzureAccount

Get-AzureSubscription

Select-AzureSubscription -SubscriptionName 'Developer Program Benefit'

Get-AzureVNetConfig -ExportToFile "$pwd\NetworkConfig.xml"





