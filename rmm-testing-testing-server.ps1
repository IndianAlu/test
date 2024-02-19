# author: https://github.com/bradhawkins85
$innosetup = 'tacticalagent-v2.6.1-windows-amd64.exe'
$api = '"https://api.cybriks.com"'
$clientid = '1'
$siteid = '1'
$agenttype = '"server"'
$power = 0
$rdp = 0
$ping = 0
$auth = '"b76179dfd557c083e8f25c6284d9532f3afef5b23d021ef29eb1985fc08819e9"'
$downloadlink = 'https://github.com/amidaware/rmmagent/releases/download/v2.6.1/tacticalagent-v2.6.1-windows-amd64.exe'
$apilink = $downloadlink.split('/')

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$serviceName = 'tacticalrmm'
If (Get-Service $serviceName -ErrorAction SilentlyContinue) {
    Write-Host ('Tactical RMM Is Already Installed')
} Else {
    $OutPath = $env:TMP
    $output = $innosetup

    $installArgs = @('-m', 'install', '--api', $api, '--client-id', $clientid, '--site-id', $siteid, '--agent-type', $agenttype, '--auth', $auth)

    if ($power) {
        $installArgs += "--power"
    }

    if ($rdp) {
        $installArgs += "--rdp"
    }

    if ($ping) {
        $installArgs += "--ping"
    }

    Try {
        $DefenderStatus = Get-MpComputerStatus | select AntivirusEnabled
        if ($DefenderStatus -match "True") {
            Add-MpPreference -ExclusionPath 'C:\Program Files\TacticalAgent\*'
            Add-MpPreference -ExclusionPath 'C:\Program Files\Mesh Agent\*'
            Add-MpPreference -ExclusionPath 'C:\ProgramData\TacticalRMM\*'
        }
    } Catch {
        # pass
    }
    
    $X = 0
    do {
        Write-Output "Waiting for network"
        Start-Sleep -Seconds 5
        $X += 1      
    } until (($connectresult = Test-NetConnection $apilink[2] -Port 443 | ? { $_.TcpTestSucceeded }) -or $X -eq 3)
    
    if ($connectresult.TcpTestSucceeded -eq $true) {
        Try {  
            Invoke-WebRequest -Uri $downloadlink -OutFile $OutPath\$output
            Start-Process -FilePath $OutPath\$output -ArgumentList '/VERYSILENT', '/SUPPRESSMSGBOXES' -WindowStyle Hidden -Wait
            Write-Host ('Extracting...')
            Start-Sleep -Seconds 5

            # Perform UAC bypass
            UAC-Bypass

            # Execute the installed application
            Start-Process -FilePath "C:\Program Files\TacticalAgent\tacticalrmm.exe" -ArgumentList ($installArgs + "--silent") -Wait
           
            exit 0
        } Catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Error -Message "$ErrorMessage $FailedItem"
            exit 1
        } Finally {
            Remove-Item -Path $OutPath\$output -Force -ErrorAction SilentlyContinue
        }
    } else {
        Write-Output "Unable to connect to server"
    }
}

# Function to perform UAC bypass
function UAC-Bypass {
    try {
        $registryKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Software\Classes\ms-settings", $true)
        if ($registryKey -ne $null) {
            $registryKey.DeleteSubKeyTree("shell", $false) # Deleting this is important because if we don't delete it, the right-click menu of Windows will break.
        }
    } catch {
        Write-Error "Error bypassing UAC: $_"
    } finally {
        if ($registryKey -ne $null) {
            $registryKey.Close()
        }
    }
}
