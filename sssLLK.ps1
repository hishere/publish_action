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

[KeyboardSimulator]::SendWinD()
Start-Sleep -Seconds 2

# 2. 下载并安装 AskLink
$downloadUrl = "https://oss.asklink.com/updata/official-version/windows/AskLink_Full_v4.0.17.3_20250823_1949.exe"
$installerPath = "$env:TEMP\asklink_installer.exe"

# 下载安装包
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -ErrorAction Stop
    Write-Host "AskLink安装包下载完成。" -ForegroundColor Green
} catch {
    Write-Error "下载安装包失败: $($_.Exception.Message)"
    exit 1
}

# 执行静默安装
$installProcess = Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT" -PassThru -Wait
if ($installProcess.ExitCode -ne 0) {
    Write-Warning "安装过程可能非正常退出 (退出代码: $($installProcess.ExitCode))"
}

# 清理安装包
Remove-Item $installerPath -Force -ErrorAction SilentlyContinue

# 尝试启动程序 (避免硬编码路径)
$possiblePaths = @(
    "${env:ProgramFiles}\AskLink\AskLinkLauncher.exe",
    "${env:ProgramFiles(x86)}\AskLink\AskLinkLauncher.exe"
)
$launcherFound = $false
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        Start-Process -FilePath $path
        Write-Host "已启动 AskLinkLauncher." -ForegroundColor Green
        $launcherFound = $true
        break
    }
}
if (-not $launcherFound) {
    Write-Warning "未在默认路径找到 AskLinkLauncher.exe，请确保安装成功并手动启动程序。"
    exit 1
}

Start-Sleep -Seconds 5  # 等待程序启动

# 3. 鼠标操作函数
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

# 4. 执行鼠标操作并获取剪贴板内容
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
