function Connect-AMP-AzAccount()
{
    $context = Get-AzContext
    if (!$context) {
        Connect-AzAccount -TenantId f7484ded-966f-49aa-b4d2-199fbac341ec
        Set-AzContext -Subscription "Sandbox"
    }
    else {
        Write-Host " すでに$($context.Name)というアカウントに接続されています。"
    }
}
Connect-AMP-AzAccount

$a = Get-AzStorageAccount -ResourceGroupName "rg-x-sbx-ampdigital" -Name "amptgenfs"

Set-AzStorageAccount -ResourceGroupName "rg-x-sbx-ampdigital" -Name "amptgenfs" -MinimumTlsVersion TLS1_2