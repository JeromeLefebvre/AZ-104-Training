<#
このスクリプトがAzure Filesのストレージを作成し、必要なフォルダーも作成する。

最終的に
* ストレージアカウント
    * amptgengs{ランダム数字}
        * File Shares
            * test-p-amp{ランダム数字}
                * Installers
                    * PI
                        * sample.md
#>

$resourceGroupName = "rg-x-sbx-ampdigital"
$region = "australiaeast"
$subscription = "Sandbox"

# 
function Connect-AMP-AzAccount()
{
    $context = Get-AzContext
    if (!$context) {
        Connect-AzAccount -TenantId f7484ded-966f-49aa-b4d2-199fbac341ec
        Set-AzContext -Subscription $subscription
    }
    else {
        Write-Host " すでに$($context.Name)というアカウントに接続されています。"
    }
}

function New-AMP-AzStorageAccount {
    <#
        .DESCRIPTION
        新規のストレージのアカウントを作成する。すでにある場合は、ストレージアカウントを返す
    #>
    param(
        [string] $location = "australiaeast",
        [string] $name = "amptgenfs$(Get-Random)",
        [string] $resourceGroupName = "rg-x-sbx-ampdigital"
    )
    $storageAcct = Get-AzStorageAccount `
      -ResourceGroupName $resourceGroupName `
      -Name $name `
      -erroraction 'silentlycontinue' 
    if ($storageAcct) {
        return $storageAcct
    }
    $storageAcct = New-AzStorageAccount `
      -ResourceGroupName $resourceGroupName `
      -Name $name `
      -Location $region `
      -Kind StorageV2 `
      -SkuName Standard_LRS `
      -EnableLargeFileShare
    return $storageAcct
}

function Remove-AMP-AzResource {
    param(
        [string] $ResourceType,
        [string] $name = "amptgenfs$(Get-Random)",
        [string] $resourceGroupName = "rg-x-sbx-ampdigital"
    )
    Remove-AzResource `
    -ResourceGroupName resourceGroupName `
    -ResourceName $name `
    -ResourceType $ResourceType
}

Connect-AMP-AzAccount
$storageAcct = New-AMP-AzStorageAccount -name "amptgenfs"
Read-Host "$($storageAcct.StorageAccountName)というストレージアカウントが作成されたと確認してください"

#TODO: 自動にこのリソースを削除できない理由を調べる
#Remove-AMP-AzResource -name $storageAcct.StorageAccountName -ResourceType $storageAcct.Kind
Write-Host "$($storageAcct.StorageAccountName)というストレージアカウントを手動で削除してください"
