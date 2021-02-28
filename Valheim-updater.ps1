$Config = Get-Content "C:\SteamCMD\Valheim-server.config" | convertfrom-json
Write-Host "Valheim Server Updater Ver 1.5" -ForegroundColor DarkGreen -BackgroundColor Black
write-host "-------------------------------"
Start-Sleep -Seconds 1.5

Function Start-Valheim {
    #Starts the Valheim Server
    $Process = get-process valheim_server -ErrorAction SilentlyContinue
    if ($Process){
        write-host "Server is running.."
    }else {
        write-host "Starting the server $($config.servername).. "
        $env:SteamAppId="892970"
        Start-Process "$($config.forceinstalldir)\valheim_server.exe" -ArgumentList "-nographics -batchmode -name $($config.servername) -port $($config.port) -password $($config.password) -public 1"
    }
}
Function Update-Valheim {
    #Starts updating the Valheim Server
    $Process = get-process valheim_server -ErrorAction SilentlyContinue
    if ($Process){
        write-host "Stop the game server first: Stop-Valheim"
    }else {
        Write-Host "Updating $($config.servername)"
        Start-Process "$($config.steamcmd)" -ArgumentList "+login anonymous +force_install_dir $($config.forceinstalldir) +app_update $($config.gameid) validate +exit" -wait
    }
}
Function Stop-Valheim {
    #Sends Ctrl+C to the Valheim window, which saves the server first and shuts down cleanly
    $Process = get-process valheim_server -ErrorAction SilentlyContinue
    if ($Process){
        $MemberDefinition = '
        [DllImport("kernel32.dll")]public static extern bool FreeConsole();
        [DllImport("kernel32.dll")]public static extern bool AttachConsole(uint p);
        [DllImport("kernel32.dll")]public static extern bool GenerateConsoleCtrlEvent(uint e, uint p);
        public static void SendCtrlC(uint p) {
            FreeConsole();
            AttachConsole(p);
            GenerateConsoleCtrlEvent(0, p);
            FreeConsole();
            AttachConsole(uint.MaxValue);
        }'
        Add-Type -Name 'dummyName' -Namespace 'dummyNamespace' -MemberDefinition $MemberDefinition
        [dummyNamespace.dummyName]::SendCtrlC($Process.ID)
    } else {
        write-host "no process found, not terminating anything"
    }
}
Function Get-ValheimCurrentVersion {
    ((Get-Content "$($config.forceinstalldir)\steamapps\appmanifest_$($config.gameid).acf" | Where-Object {$_ -like "*buildid*"}).split('"').trim() | Where-Object {$_})[-1]
}
Function Get-ValheimLatestVersion {
    Write-Host "Checking Steam API for latest version..."
    $Data = Invoke-WebRequest -Uri "https://api.steamcmd.net/v1/info/$($config.gameid)" -UseBasicParsing
    $json = $data.content | convertfrom-json
    $BuildID = $json.data.$($config.gameid).depots.branches.public.buildid
    $Status = $json.status
    
    if ($Status -eq 'success') {
    Write-Host "Status: Success!" -ForegroundColor DarkGreen
    } else {
    Write-Host "Error, unable to contact the Steam services. Trying again later.." -ForegroundColor Red    
    }


Return $BuildID

Start-Sleep -Seconds 1.5

}
#Run every 300 seconds forever
$stop = "$false"
do{
    $BuildID = Get-ValheimLatestVersion
    $CurrentBuildID = Get-ValheimCurrentVersion
    
    if ($BuildID -ne $CurrentBuildID){
        #New version detected. Initiating patching
        Stop-Valheim
        Update-Valheim
    } else {
        Write-host "Server is on the latest update: $($BuildID)"
       
    }
    #This will start Valheim after patching, and even if it's not patched but crashed for some reason
    Start-Valheim
    #Will run every 5 minutes (300 seconds)
    Start-Sleep -Seconds 300
} while ($stop)

