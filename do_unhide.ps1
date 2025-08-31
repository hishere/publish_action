#启用扩展名
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
Stop-Process -Name "explorer" -Force
Write-Host "File extensions are now visible. Explorer will restart automatically."

#启动chrome并关闭
# Chrome无头模式启动并立即关闭脚本

# 设置Chrome路径（如果不在默认路径，请修改此处）
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"

# 检查Chrome是否存在
if (-not (Test-Path $chromePath)) {
    Write-Host "错误: 未找到Chrome浏览器，请检查路径或安装Chrome。" -ForegroundColor Red
    exit 1
}

# 方法1: 使用超时参数立即退出
Write-Host "方法1: 使用超时参数启动无头Chrome并立即关闭..." -ForegroundColor Yellow
& $chromePath --headless=new --disable-gpu --timeout=1 --disable-dev-shm-usage about:blank

# 添加短暂延迟以确保进程完全退出
Start-Sleep -Milliseconds 500

# 方法2: 启动后立即强制终止进程
Write-Host "`n方法2: 启动无头Chrome后立即强制关闭..." -ForegroundColor Yellow
$process = Start-Process -FilePath $chromePath -ArgumentList " --disable-gpu --disable-dev-shm-usage about:blank" -PassThru
Start-Sleep -Seconds 1
if (-not $process.HasExited) {
    $process | Stop-Process -Force
    Write-Host "已强制终止Chrome进程。" -ForegroundColor Green
}

# 验证无Chrome进程残留
$chromeProcesses = Get-Process -Name "chrome" -ErrorAction SilentlyContinue
if ($chromeProcesses) {
    Write-Host "警告: 发现残留Chrome进程，正在清理..." -ForegroundColor Yellow
    $chromeProcesses | Stop-Process -Force
} else {
    Write-Host "状态: 无残留Chrome进程。" -ForegroundColor Green
}

Write-Host "`n脚本执行完成！" -ForegroundColor Cyan