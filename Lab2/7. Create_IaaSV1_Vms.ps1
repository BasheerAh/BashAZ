
Function Create-VM ($svrname, $servicename, $stype, $loc, $vmno, $vnet)
# Create an IaaS v1 virtual machine

{

    # Set variables
    $dnsname = 'ADATUM-DNS'    #Note: hard-coded in NetworkConfig.xml
    $subnet = 'Subnet-1'       #Note: hard-coded in NetworkConfig.xml
    $global:adminname = 'Student'
    $global:adminpassword = 'Pa$$word123'
    $RDPfilesdir = "$pwd\"
    $RDPendpoint = 3388 + $vmno
    $PSendpoint = 5985 + $vmno
    $instancesize = 'Small'    #Should be standard tier

    $svrimage = (Get-AzureVMImage | Where-Object { $_.ImageFamily -like "Windows Server 2012 R2*" } | Where-Object { $_.Location.Split(";") -contains $loc} | Sort-Object -Property PublishedDate -Descending)[0].ImageName

    # Set DNS
    $dns = New-AzureDns -IPAddress 10.0.0.4 -Name $dnsname

    # Set the instance-specific variables
    If ($stype -EQ 'Server') { $winimage = $svrimage }

    $newVM = New-AzureVMConfig -name $svrname -InstanceSize $instancesize -ImageName $winimage | Add-AzureProvisioningConfig -Windows -AdminUsername $adminname -Password $adminpassword | Set-AzureEndpoint -Name "RemoteDesktop" -Protocol tcp -LocalPort 3389 -PublicPort $RDPendpoint | Set-AzureEndpoint -Name "PowerShell" -Protocol tcp -LocalPort 5986 -PublicPort $PSendpoint | Set-AzureSubnet -SubnetNames $subnet | Set-AzureVMBGInfoExtension -ReferenceName 'BGInfo'

    #Check if this is the first VM in the deployment
    $ErrorActionPreference = "SilentlyContinue"
    $deployment = Get-AzureService -ServiceName $servicename
    $ErrorActionPreference = "Continue"
    If ($deployment.ServiceName -eq $null) { 
        New-AzureVM -ServiceName $servicename -Location $loc -VMs $newVM -VNetName $vnet -WaitForBoot
    }
    Else {
        New-AzureVM -ServiceName $servicename -VMs $newVM -WaitForBoot
    }     

    $VMStatus = Get-AzureVM -ServiceName $servicename -Name $svrname
    While ($VMStatus.InstanceStatus -ne "ReadyRole")
    {
        Start-Sleep -Seconds 60
    $VMStatus = Get-AzureVM -ServiceName $servicename -Name $svrname
    }

    Start-Sleep -Seconds 60

    # Download the RDP file for this VM
    Get-AzureRemoteDesktopFile -ServiceName $servicename -Name $svrname -LocalPath "$RDPfilesdir$svrname.rdp" 

} 

Function Create-Storage ($fName, $fLocation, $subscriptionName)
# Set the current storage account

{

    # Get the default subscription name
    $subname = $subscriptionName
    foreach ($sub in Get-AzureSubscription) {
        if ($sub.IsDefault -eq "True")
        {
            $subname = $sub.SubscriptionName
        }
    }

    Write-Host "Storage is:" $fName
    Write-Host "Location is:" $fLocation

    New-AzureStorageAccount -StorageAccountName $fName -Location $fLocation
    Set-AzureSubscription -SubscriptionName $subname -CurrentStorageAccountName $fName

}


Add-AzureAccount

Get-AzureSubscription

$subscriptionName = "Developer Program Benefit"

Select-AzureSubscription -SubscriptionName $subscriptionName

$servicename = "WebC"
$locName = "Southeast Asia"
$vnet = 'ADATUM-BRANCH-VNET'  

$randNo = (Get-date).Ticks.ToString().Substring(12)
Create-Storage -fName "sta$randNo" -fLocation $locName -subscriptionName $subscriptionName

Create-VM -svrname cn1 -servicename $servicename -stype Server -loc $locName -vmno 1 -vnet $vnet
Create-VM -svrname cn2 -servicename $servicename -stype Server -loc $locName -vmno 2 -vnet $vnet