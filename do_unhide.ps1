#启用扩展名
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
Stop-Process -Name "explorer" -Force
Write-Host "File extensions are now visible. Explorer will restart automatically."

Start-Sleep -Seconds 3

#启动msedge并关闭
Start-Process -FilePath "msedge.exe"
Start-Process -FilePath "chrome.exe"

Start-Sleep -Seconds 3

Stop-Process -Name "msedge" -Force
Stop-Process -Name "chrome" -Force
