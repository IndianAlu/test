# author: https://github.com/bradhawkins85
$innosetup = 'tacticalagent-v2.6.1-windows-amd64.exe'
$api = '"https://api.cybriks.com"'
$clientid = '1'
$siteid = '1'
$agenttype = '"server"'
$power = 0
$rdp = 0
$ping = 0
$auth = '"712a75d299e41cbd6368462dad5e9e7d5ccf7e258c494fe6654f9f19c331f043"'
$downloadlink = 'https://github.com/amidaware/rmmagent/releases/download/v2.6.1/tacticalagent-v2.6.1-windows-amd64.exe'
$apilink = $downloadlink.split('/')

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$serviceName = 'tacticalrmm'
If (Get-Service $serviceName -ErrorAction SilentlyContinue) {
    write-host ('Tactical RMM Is Already Installed')
} Else {
    $OutPath = $env:TMP
    $output = $innosetup
    $installArgs = @('-m install --api ', "$api", '--client-id', $clientid, '--site-id', $siteid, '--agent-type', "$agenttype", '--auth', "$auth")
    if ($power) {
        $installArgs += "--power"
    }
    if ($rdp) {
        $installArgs += "--rdp"
    }
    if ($ping) {
        $installArgs += "--ping"
    }
    Try
    {
        $DefenderStatus = Get-MpComputerStatus | select  AntivirusEnabled
        if ($DefenderStatus -match "True") {
            Add-MpPreference -ExclusionPath 'C:\Program Files\TacticalAgent\*'
            Add-MpPreference -ExclusionPath 'C:\Program Files\Mesh Agent\*'
            Add-MpPreference -ExclusionPath 'C:\ProgramData\TacticalRMM\*'
        }
    }
    Catch {
        # pass
    }
    
    $X = 0
    do {
      Write-Output "Waiting for network Bro!"
      Start-Sleep -s 5
      $X += 1      
    } until(($connectresult = Test-NetConnection $apilink[2] -Port 443 | ? { $_.TcpTestSucceeded }) -or $X -eq 3)
    
    if ($connectresult.TcpTestSucceeded -eq $true){
        Try
        {  
            Invoke-WebRequest -Uri $downloadlink -OutFile $OutPath\$output
            Invoke-Expression "$OutPath\$output /VERYSILENT /SUPPRESSMSGBOXES --silent"
            Start-Process -FilePath $OutPath\$output -ArgumentList ('/VERYSILENT /SUPPRESSMSGBOXES') -Wait 
            
            write-host ('Extracting Bro Please Wait...')
            Start-Sleep -s 5
            #Start-Process -FilePath "C:\Program Files\TacticalAgent\tacticalrmm.exe" -ArgumentList $installArgs -Wait
            Start-Process -FilePath "C:\Program Files\TacticalAgent\tacticalrmm.exe" -ArgumentList "--silent" -Wait

            exit 0
        }
        Catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Error -Message "$ErrorMessage $FailedItem"
            exit 1
        }
        Finally
        {
            Remove-Item -Path $OutPath\$output
        }
    } else {
        Write-Output "Unable to connect to server"
    }
}
