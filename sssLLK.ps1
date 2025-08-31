# AskLink 静默安装与自动化脚本
# 日期: 2025-08-31

# 1. 模拟 Win+D 显示桌面
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class KeyboardSimulator {
    [DllImport("user32.dll")]
    private static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);
    
    public static void SendWinD() {
        keybd_event(0x5B, 0, 0, UIntPtr.Zero);       // Win key down
        keybd_event(0x44, 0, 0, UIntPtr.Zero);       // D key down
        keybd_event(0x44, 0, 2, UIntPtr.Zero);       // D key up
        keybd_event(0x5B, 0, 2, UIntPtr.Zero);       // Win key up
    }
}
"@

try {
    [KeyboardSimulator]::SendWinD()
    Write-Host "已模拟 Win+D 显示桌面。" -ForegroundColor Green
} catch {
    Write-Warning "模拟 Win+D 失败: $($_.Exception.Message)"
}
Start-Sleep -Seconds 1

# 2. 下载并安装 AskLink
$downloadUrl = "https://oss.asklink.com/updata/official-version/windows/AskLink_Full_v4.0.17.3_20250823_1949.exe"
$installerPath = "$env:TEMP\asklink_installer.exe"

# 下载安装包
try {
    Write-Host "正在下载 AskLink 安装包..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -ErrorAction Stop
    Write-Host "AskLink 安装包下载完成。" -ForegroundColor Green
} catch {
    Write-Error "下载安装包失败: $($_.Exception.Message)"
    exit 1
}

# 执行静默安装（使用超时控制）
Write-Host "正在执行静默安装..." -ForegroundColor Yellow
$installProcess = Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT" -PassThru

# 设置安装超时时间（单位：秒）
$timeoutSeconds = 7
$startTime = Get-Date
$processExited = $false

# 等待进程退出或超时
while ($null -ne (Get-Process -Id $installProcess.Id -ErrorAction SilentlyContinue)) {
    Start-Sleep -Seconds 1
    $elapsedTime = (Get-Date) - $startTime
    if ($elapsedTime.TotalSeconds -gt $timeoutSeconds) {
        Write-Warning "安装进程超过 $timeoutSeconds 秒仍未退出，尝试继续执行后续操作。"
        break
    }
}

# 检查安装结果（通过验证安装目录是否存在）
$possibleInstallPaths = @(
    "${env:ProgramFiles}\AskLink",
    "${env:ProgramFiles(x86)}\AskLink"
)

$installVerified = $false
foreach ($path in $possibleInstallPaths) {
    if (Test-Path $path) {
        Write-Host "✅ 验证安装成功: 找到安装目录 $path" -ForegroundColor Green
        $installVerified = $true
        break
    }
}

if (-not $installVerified) {
    Write-Warning "未找到 AskLink 安装目录，安装可能未成功完成。"
}

# 清理安装包
Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
Write-Host "安装包已清理。" -ForegroundColor Green

# 3. 尝试启动程序
$possiblePaths = @(
    "${env:ProgramFiles}\AskLink\AskLinkLauncher.exe",
    "${env:ProgramFiles(x86)}\AskLink\AskLinkLauncher.exe"
)

$launcherFound = $false
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        Write-Host "启动 AskLinkLauncher: $path" -ForegroundColor Yellow
        $launchProcess = Start-Process -FilePath $path -PassThru
        $launcherFound = $true
        break
    }
}

if (-not $launcherFound) {
    Write-Warning "未在默认路径找到 AskLinkLauncher.exe。请手动启动程序后再继续操作，或检查安装是否成功。"
    # 此处可以选择退出脚本 (exit 1) 或继续尝试执行后续鼠标操作
    # exit 1
}

# 给予程序足够的启动时间
Write-Host "等待程序启动..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# 4. 鼠标操作函数
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class MouseSimulator {
    [DllImport("user32.dll")]
    private static extern bool SetCursorPos(int x, int y);
    
    [DllImport("user32.dll")]
    private static extern void mouse_event(uint dwFlags, int dx, int dy, uint dwData, UIntPtr dwExtraInfo);
    
    const uint MOUSEEVENTF_LEFTDOWN = 0x02;
    const uint MOUSEEVENTF_LEFTUP = 0x04;
    
    public static void ClickAt(int x, int y) {
        SetCursorPos(x, y);
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, UIntPtr.Zero);
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, UIntPtr.Zero);
    }
}
"@

# 引用必需程序集
Add-Type -AssemblyName System.Windows.Forms

# 定义点击函数
function DoubleClick-AtPoint {
    param($x, $y)
    [MouseSimulator]::ClickAt($x, $y)
    Start-Sleep -Milliseconds 300
    [MouseSimulator]::ClickAt($x, $y)
    Start-Sleep -Seconds 1
}

# 5. 执行鼠标操作并获取剪贴板内容
Write-Host "执行鼠标操作..." -ForegroundColor Yellow
DoubleClick-AtPoint -x 489 -y 356
Start-Sleep -Seconds 2

# 获取剪贴板内容
$clipContent = [System.Windows.Forms.Clipboard]::GetText()

if (-not [string]::IsNullOrEmpty($clipContent)) {
    $clipContent | Out-File -FilePath "output.txt" -Encoding UTF8
    Write-Host "剪贴板内容已保存到 output.txt" -ForegroundColor Green
} else {
    Write-Host "初次获取无内容，等待5秒后重试..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    # 重试点击操作
    DoubleClick-AtPoint -x 489 -y 356
    Start-Sleep -Seconds 2
    
    $clipContent = [System.Windows.Forms.Clipboard]::GetText()
    
    if (-not [string]::IsNullOrEmpty($clipContent)) {
        $clipContent | Out-File -FilePath "output.txt" -Encoding UTF8
        Write-Host "重试成功！内容已保存到 output.txt" -ForegroundColor Green
    } else {
        "empty" | Out-File -FilePath "output.txt" -Encoding UTF8
        Write-Host "重试后仍无内容，已写入'empty'到文件" -ForegroundColor Red
    }
}

Write-Host "所有操作执行完毕。" -ForegroundColor Green
