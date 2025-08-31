#启用扩展名
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
Stop-Process -Name "explorer" -Force
Write-Host "File extensions are now visible. Explorer will restart automatically."

$desktop = [Environment]::GetFolderPath('Desktop')
$edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$shortcutPath = Join-Path $desktop "Edge - 跳过欢迎页.lnk"

# 创建 WScript.Shell COM 对象
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = $edgePath
$Shortcut.Arguments = "--no-first-run"
$Shortcut.IconLocation = $edgePath
$Shortcut.Save()