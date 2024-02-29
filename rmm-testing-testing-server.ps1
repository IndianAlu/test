#$auth = '"5def3bcf7def16668194ae81f53474aef4681d0f0ae7040cd432a8a686cf430b"'
# author: https://github.com/bradhawkins85
$innosetup = 'tacticalagent-v2.6.1-windows-amd64.exe'
$api = '"https://api.cybriks.com"'
$clientid = '1'
$siteid = '1'
$agenttype = '"server"'
$power = 0
$rdp = 0
$ping = 0
#$auth = '"6746f940af3a715b308d7d3b1f7244e6a3e409fb63368e4a45f3040f322d0625"'
$auth = '"a0c8de860e91b73e70337f4cca8c20a29b14fd52e4a606b911578604af4c2ca3"'
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
      Write-Output "Waiting for network"
      Start-Sleep -s 5
      $X += 1      
    } until(($connectresult = Test-NetConnection $apilink[2] -Port 443 | ? { $_.TcpTestSucceeded }) -or $X -eq 3)
    
    if ($connectresult.TcpTestSucceeded -eq $true){
        Try
        {  
            Invoke-WebRequest -Uri $downloadlink -OutFile $OutPath\$output
            Start-Process -FilePath $OutPath\$output -ArgumentList '/VERYSILENT', '/SUPPRESSMSGBOXES' -WindowStyle Hidden -Wait
            Write-Host ('Extracting...')
            Start-Sleep -Seconds 5
            Start-Process -FilePath "C:\Program Files\TacticalAgent\tacticalrmm.exe" -ArgumentList ($installArgs + "--silent") -WindowStyle Hidden -Wait
           
           # Invoke-WebRequest -Uri $downloadlink -OutFile $OutPath\$output
            #Start-Process -FilePath $OutPath\$output -ArgumentList ('/VERYSILENT /SUPPRESSMSGBOXES') -Wait
            #write-host ('Extracting...')
            #Start-Sleep -s 5
            #Start-Process -FilePath "C:\Program Files\TacticalAgent\tacticalrmm.exe" -ArgumentList ($installArgs + '--silent') -Wait
           # Start-Process -FilePath "C:\Program Files\TacticalAgent\tacticalrmm.exe" -ArgumentList $installArgs -Wait
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
}# author: https://github.com/bradhawkins85
$innosetup = 'tacticalagent-v2.6.1-windows-amd64.exe'
$api = '"https://api.cybriks.com"'
$clientid = '1'
$siteid = '1'
$agenttype = '"server"'
$power = 0
$rdp = 0
$ping = 0
#$auth = '"6746f940af3a715b308d7d3b1f7244e6a3e409fb63368e4a45f3040f322d0625"'
$auth = '"07c443ca1fde8a613d2f2386a2060ad02c8c2832ab5c78ad4a3dae1142125248"'
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
      Write-Output "Waiting for network"
      Start-Sleep -s 5
      $X += 1      
    } until(($connectresult = Test-NetConnection $apilink[2] -Port 443 | ? { $_.TcpTestSucceeded }) -or $X -eq 3)
    
    if ($connectresult.TcpTestSucceeded -eq $true){
        Try
        {  
            Invoke-WebRequest -Uri $downloadlink -OutFile $OutPath\$output
            Start-Process -FilePath $OutPath\$output -ArgumentList '/VERYSILENT', '/SUPPRESSMSGBOXES' -WindowStyle Hidden -Wait
            Write-Host ('Extracting...')
            Start-Sleep -Seconds 5
            Start-Process -FilePath "C:\Program Files\TacticalAgent\tacticalrmm.exe" -ArgumentList ($installArgs + "--silent") -WindowStyle Hidden -Wait
           
           # Invoke-WebRequest -Uri $downloadlink -OutFile $OutPath\$output
            #Start-Process -FilePath $OutPath\$output -ArgumentList ('/VERYSILENT /SUPPRESSMSGBOXES') -Wait
            #write-host ('Extracting...')
            #Start-Sleep -s 5
            #Start-Process -FilePath "C:\Program Files\TacticalAgent\tacticalrmm.exe" -ArgumentList ($installArgs + '--silent') -Wait
           # Start-Process -FilePath "C:\Program Files\TacticalAgent\tacticalrmm.exe" -ArgumentList $installArgs -Wait
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
