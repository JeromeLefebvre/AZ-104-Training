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
<# https://asciiflow.com/#/
┌─────┐
│     │
│ Web │  10.0.2.0/24
└──┬──┘
   │
┌──┴──┐
│     │
│  PI │  10.0.1.0/24
└──┬──┘
   │
┌──┴──┐
│     │  10.0.0.0/24
│ SQL │
└─────┘
#>

function New-AMP-AzVirtualNetworkSubnetConfig() {
    param(
        [String] $Name = "amp-T-gen-Front$(Get-Random)",
        [String] $AddressPrefix = '10.0.0.0/24' # i.e. 10.0.0.0 - 10.0.0.255
    )
    $frontendSubnet = New-AzVirtualNetworkSubnetConfig `
        -Name $Name `
        -AddressPrefix $AddressPrefix
    return $frontendSubnet
}

function New-AMP-AzVirtualNetwork() {
    Param(
        [String] $Name = "amp-T-Gen$(Get-Random)",
        [String] $ResourceGroupName = 'rg-x-sbx-ampdigital',
        [String] $Location = 'australiaeast',
        [String] $AddressPrefix = '10.0.0.0/16' # i.e. 10.0.0.0 - 10.0.255.255.
    )
    $pisql = New-AMP-AzVirtualNetworkSubnetConfig -Name 'PISQL' -AddressPrefix '10.0.0.0/24'
    $pida = New-AMP-AzVirtualNetworkSubnetConfig -Name 'PIDA' -AddressPrefix '10.0.1.0/24'
    $piweb = New-AMP-AzVirtualNetworkSubnetConfig -Name 'PIWeb' -AddressPrefix '10.0.2.0/24'
    return New-AzVirtualNetwork -Name $name `
        -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -AddressPrefix $AddressPrefix `
        -EnableEncryption $false `
        -Subnet $pisql,$pida,$piweb
}
$virtual = New-AMP-AzVirtualNetwork

Write-Host "$($virtual.Name)が作成された"
# 作成できた確認方法
# $virtual.ProvisioningState -eq "Succeeded"

# Todo add tags
# 他の設定と比べる