#启用扩展名
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
Stop-Process -Name "explorer" -Force
Write-Host "File extensions are now visible. Explorer will restart automatically."

# 获取桌面路径
$desktop = [Environment]::GetFolderPath('Desktop')

# 各浏览器可执行文件路径（如有不同请自行调整）
$edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$firefoxPath = "C:\Program Files\Mozilla Firefox\firefox.exe"

# 创建 WScript.Shell COM 对象
$WshShell = New-Object -ComObject WScript.Shell

# Edge 跳过欢迎页
$edgeShortcut = $WshShell.CreateShortcut((Join-Path $desktop "Edge - 跳过欢迎页.lnk"))
$edgeShortcut.TargetPath = $edgePath
$edgeShortcut.Arguments = "--no-first-run"
$edgeShortcut.IconLocation = $edgePath
$edgeShortcut.Save()

# Chrome 跳过欢迎页
$chromeShortcut = $WshShell.CreateShortcut((Join-Path $desktop "Chrome - 跳过欢迎页.lnk"))
$chromeShortcut.TargetPath = $chromePath
$chromeShortcut.Arguments = "--no-first-run"
$chromeShortcut.IconLocation = $chromePath
$chromeShortcut.Save()

# Firefox 跳过欢迎页
$firefoxShortcut = $WshShell.CreateShortcut((Join-Path $desktop "Firefox - 跳过欢迎页.lnk"))
$firefoxShortcut.TargetPath = $firefoxPath
$firefoxShortcut.Arguments = "-no-remote -new-instance -url about:blank"
$firefoxShortcut.IconLocation = $firefoxPath
$firefoxShortcut.Save()