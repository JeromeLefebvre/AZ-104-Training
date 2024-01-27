$resourceGroupName = "rg-x-sbx-ampdigital"
$region = "australiaeast"
$subscription = "Sandbox"

# 
function Connect-AMP-AzAccount()　{
    $context = Get-AzContext
    if (!$context) {
        Connect-AzAccount -TenantId f7484ded-966f-49aa-b4d2-199fbac341ec
        Set-AzContext -Subscription $subscription
    }
    else {
        Write-Host " すでに$($context.Name)というアカウントに接続されています。"
    }
}

function New-AMP-AzVm() {
    param (
        [String] $Name
    )
    New-AzVm `
        -ResourceGroupName 'rg-x-sbx-ampdigital' `
        -Name $Name `
        -Location 'australiaeast' `
        -Image 'MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest' `
        -VirtualNetworkName 'amp-T-Gen483220716' `
        -SubnetName 'PISQL' `
        -PublicIpAddressName 'myPublicIpAddress' `
        -OpenPorts 80,3389
}
Connect-AMP-AzAccount
