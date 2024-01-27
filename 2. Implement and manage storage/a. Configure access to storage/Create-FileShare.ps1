<#
このスクリプトがAzure Filesのストレージを作成し、必要なフォルダーも作成する。

TODO:　手動で作成されたファイル共有と自動に作成されたファイル共有を比べる
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
      -EnableLargeFileShare　`
      -MinimumTlsVersion TLS1_2
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

function New-AMP-AzRmStorageShare {
    param(
        [System.Object] $StorageAccount, # PSStorageAccountの指定の仕方
        [string] $Name = "sharedrive$(Get-Random)",
        [Int32] $QuotaGiB = 10
    )
    $sharedStorage = Get-AzRmStorageShare -StorageAccount $storageAcct -Name $Name -ErrorAction SilentlyContinue
    if ($sharedStorage) {
        return $sharedStorage
    }
    $sharedStorage = New-AzRmStorageShare `
      -StorageAccount $storageAcct `
      -Name $Name `
      -EnabledProtocol SMB `
      -QuotaGiB 10 # | Out-Null    
    return $sharedStorage
}
Connect-AMP-AzAccount
$storageAcct = New-AMP-AzStorageAccount -name "amptgenfs"
# Read-Host "$($storageAcct.StorageAccountName)というストレージアカウントが作成されたと確認してください"
Write-Host "$($storageAcct.StorageAccountName)というストレージアカウントが作成されました"

# One time fix to the Update the TLS version


$ctx = New-AzStorageContext -StorageAccountName $storageAcct.StorageAccountName -UseConnectedAccount

#　すでにある場合は現在のファイルshareを返す
$sharedStorage = New-AMP-AzRmStorageShare -StorageAccount $storageAcct -Name "installers"

Write-Host "$($sharedStorage.Name)というファイルシャーが作成されました"

function New-AMP-AzStorageDirectory {
    param(
        [Microsoft.WindowsAzure.Commands.Common.Storage.AzureStorageContext] $Context,
        [string] $ShareName,
        [string] $Path
    )
    # すでにある場合はエラーを無視する
    New-AzStorageDirectory `
      -Context $context `
      -ShareName $ShareName `
      -Path $path -ErrorAction SilentlyContinue
}

@(
    "PI",
    "PI/PIVision",
    "PI/PIWebAPI"
) | ForEach-Object {New-AMP-AzStorageDirectory `
   -Context $storageAcct.Context `
   -ShareName $sharedStorage.Name `
   -Path $PSItem}

Set-AzStorageFileContent `
   -Context $storageAcct.Context `
   -ShareName $sharedStorage.Name `
   -Source '/Users/jeromelefebvre/GitHub/AZ-104-Training/2. Implement and manage storage/a. Configure access to storage/sample.md' `
   -Path "PI/sample.md"

#Remove-AMP-AzResource -name $storageAcct.StorageAccountName -ResourceType $storageAcct.Kind
Write-Host "$($storageAcct.StorageAccountName)というストレージアカウントを手動で削除してください"