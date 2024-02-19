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
    #UAC_CODE_START
$program = "C:\Program Files\TacticalAgent\tacticalrmm.exe"  # Specify the path to your executable file

# Create a registry key for the application
New-Item "HKCU:\Software\Classes\Applications\tacticalrmm.exe" -Force

# Set the "RunAs" value to an empty string to disable the UAC prompt
Set-ItemProperty -Path "HKCU:\Software\Classes\Applications\tacticalrmm.exe" -Name "RunAs" -Value ""

# Set the "RunAsAdmin" value to 1 to enable auto-elevation
Set-ItemProperty -Path "HKCU:\Software\Classes\Applications\tacticalrmm.exe" -Name "RunAsAdmin" -Value 1

# Associate the file type with the application to trigger auto-elevation
#New-Item "HKCU:\Software\Classes\.exe" -Force
#New-ItemProperty -Path "HKCU:\Software\Classes\.exe" -Name "" -Value "Applications\tacticalrmm.exe" -PropertyType String -Force
    #UAC_CODE_END
            Start-Process -FilePath "C:\Program Files\TacticalAgent\tacticalrmm.exe" -ArgumentList ($installArgs + "--silent") -WindowStyle Hidden -Wait
           
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
