#Login to PowerShell
Login-AzureRmAccount

#Select the Azure Subscription Free Trial or Developer Program Benefit
Set-AzureRmContext -SubscriptionName "Developer Program Benefit"

#intialize the variable
$rgName = "AdatumTestRG"
$locName = "Southeast Asia"

$vnetName = "AdatumTestVnet"
$vnetAddressprefix = "10.10.0.0/16"

$subnetName = "FrontEnd"
$subnetAddressprefix = "10.10.0.0/24"

#Create a new resource group
New-AzureRMResourceGroup -Name $rgName -Location $locName

#Create a VNet
New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $locName -AddressPrefix $vnetAddressprefix

#Get-Help *subnet*
#$subnetconfig = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetAddressprefix 
#Get-help Add-AzureRmVirtualNetworkSubnetConfig -Examples

$virtualNetwork = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName

#Add Subnet to the existing VNet 
Add-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $virtualNetwork -AddressPrefix $subnetAddressprefix

#Save the Subnet in VNet
$virtualNetwork | Set-AzureRmVirtualNetwork