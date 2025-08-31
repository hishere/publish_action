# AskLink 静默安装与自动化脚本

# 1. 模拟 Win+D 显示桌面
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class KeyboardSimulator {
    [DllImport("user32.dll")]
    private static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);
    
    public static void SendWinD() {
        keybd_event(0x5B, 0, 0, UIntPtr.Zero);
        keybd_event(0x44, 0, 0, UIntPtr.Zero);
        keybd_event(0x44, 0, 2, UIntPtr.Zero);
        keybd_event(0x5B, 0, 2, UIntPtr.Zero);
    }
}
"@

try {
    [KeyboardSimulator]::SendWinD()
    Write-Host "已模拟 Win+D 显示桌面。" -ForegroundColor Green
} catch {
    Write-Warning "模拟 Win+D 失败: $($_.Exception.Message)"
}
Start-Sleep -Seconds 2

# 2. 下载并安装 AskLink
$downloadUrl = "https://oss.asklink.com/updata/official-version/windows/AskLink_Full_v4.0.17.3_20250823_1949.exe"
$installerPath = "C:\Windows\Temp\asklink_installer.exe"

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
$timeoutSeconds = 9
$startTime = Get-Date

# 等待进程退出或超时
while ($null -ne (Get-Process -Id $installProcess.Id -ErrorAction SilentlyContinue)) {
    Start-Sleep -Seconds 2
    $elapsedTime = (Get-Date) - $startTime
    if ($elapsedTime.TotalSeconds -gt $timeoutSeconds) {
        Write-Warning "安装进程超过 $timeoutSeconds 秒仍未退出，尝试继续执行后续操作。"
        break
    }
}

# 检查安装结果（通过验证安装目录是否存在）
$installPath = "C:\Program Files\AskLink"

# 使用 Test-Path 检查安装目录是否存在
if (Test-Path $installPath) {
    Write-Host "✅ 验证安装成功: 找到安装目录 $installPath" -ForegroundColor Green
    $installVerified = $true
} else {
    Write-Warning "未找到 AskLink 安装目录，安装可能未成功完成。"
    $installVerified = $false
}

# 清理安装包
Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
Write-Host "安装包已清理。" -ForegroundColor Green

# 3. 尝试启动程序
$launcherPath = "C:\Program Files\AskLink\AskLinkLauncher.exe"

# 使用 Test-Path 检查启动程序是否存在
if (Test-Path $launcherPath) {
    Write-Host "启动 AskLinkLauncher: $launcherPath" -ForegroundColor Yellow
    $launchProcess = Start-Process -FilePath $launcherPath -PassThru
    $launcherFound = $true
} else {
    Write-Warning "未在默认路径找到 AskLinkLauncher.exe。请手动启动程序后再继续操作，或检查安装是否成功。"
    $launcherFound = $false
}

# 给予程序足够的启动时间
Write-Host "等待程序启动..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

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

# 剪贴板内容检测和处理
if (-not [string]::IsNullOrEmpty($clipContent)) {
    $clipContent | Out-File -FilePath "output.txt" -Encoding UTF8
    Write-Host "剪贴板内容已保存到 output.txt" -ForegroundColor Green
} 
else {
    # 剪贴板内容为空时进入重试流程
    Write-Host "初次获取无内容，等待5秒后重试..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    # 重试点击操作
    DoubleClick-AtPoint -x 489 -y 356
    Start-Sleep -Seconds 2
    
    # 重新获取剪贴板内容
    $clipContent = [System.Windows.Forms.Clipboard]::GetText()
    
    if (-not [string]::IsNullOrEmpty($clipContent)) {
        $clipContent | Out-File -FilePath "output.txt" -Encoding UTF8
        Write-Host "重试成功！内容已保存到 output.txt" -ForegroundColor Green
    } else {
        "empty" | Out-File -FilePath "output.txt" -Encoding UTF8
        Write-Host "重试后仍无内容，已写入'empty'到文件" -ForegroundColor Red
    }
}
