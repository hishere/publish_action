# 步骤1: 模拟 Win+D 显示桌面
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class KeyboardSimulator {
    [DllImport("user32.dll")]
    private static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);
    
    public static void SendWinD() {
        // Win 键按下 (0x5B)
        keybd_event(0x5B, 0, 0, UIntPtr.Zero);
        // D 键按下 (0x44)
        keybd_event(0x44, 0, 0, UIntPtr.Zero);
        // D 键释放
        keybd_event(0x44, 0, 2, UIntPtr.Zero);
        // Win 键释放
        keybd_event(0x5B, 0, 2, UIntPtr.Zero);
    }
}
"@
[KeyboardSimulator]::SendWinD()
Start-Sleep -Seconds 1



# 步骤3: 鼠标操作函数
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

# 执行鼠标操作序列
[MouseSimulator]::ClickAt(576,479)
Start-Sleep -Seconds 2
[MouseSimulator]::ClickAt(860, 660)
Start-Sleep -Seconds 2
[MouseSimulator]::ClickAt(860, 660)
Start-Sleep -Seconds 2

[MouseSimulator]::ClickAt(1023, 767)
Start-Sleep -Seconds 2

# 步骤2: 启动 team 并等待
# 下载TeamViewer安装程序
$downloadUrl = "https://dl.teamviewer.com/download/version_15x/TeamViewer_Setup_x64.exe"
$installerPath = "$env:TEMP\TeamViewer_Setup_x64.exe"

Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

# 执行静默安装
Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait

# 可选：安装完成后删除安装程序
Remove-Item $installerPath

Start-Process -FilePath "${env:ProgramFiles}\TeamViewer\TeamViewer.exe"

#休息一下
Start-Sleep -Seconds 3

#关闭team
# 定义 TeamViewer 进程名称
$processNames = @("TeamViewer", "TeamViewer_Service")

# 循环遍历所有需要结束的进程
foreach ($name in $processNames) {
    # 获取所有指定名称的进程
    $processes = Get-Process -Name $name -ErrorAction SilentlyContinue
    if ($processes) {
        Write-Host "正在停止进程: $name"
        # 强制结束进程
        Stop-Process -Name $name -Force
        Write-Host "已成功停止进程: $name"
    } else {
        Write-Host "未找到进程: $name"
    }
}
Write-Host "TeamViewer 关闭1操作完成。" -ForegroundColor Green

#休息一下
Start-Sleep -Seconds 3

Start-Process -FilePath "${env:ProgramFiles}\TeamViewer\TeamViewer.exe"

#休息一下
Start-Sleep -Seconds 3

#关闭team
# 定义 TeamViewer 进程名称
$processNames = @("TeamViewer", "TeamViewer_Service")

# 循环遍历所有需要结束的进程
foreach ($name in $processNames) {
    # 获取所有指定名称的进程
    $processes = Get-Process -Name $name -ErrorAction SilentlyContinue
    if ($processes) {
        Write-Host "正在停止进程: $name"
        # 强制结束进程
        Stop-Process -Name $name -Force
        Write-Host "已成功停止进程: $name"
    } else {
        Write-Host "未找到进程: $name"
    }
}
Write-Host "TeamViewer 关闭2操作完成。" -ForegroundColor Green

Start-Process -FilePath "${env:ProgramFiles}\TeamViewer\TeamViewer.exe"

#休息一下
Start-Sleep -Seconds 3

# 引用必需程序集
Add-Type -AssemblyName System.Windows.Forms

# 定义点击函数
function DoubleClick-AtPoint {
    param($x, $y)
    [MouseSimulator]::ClickAt($x, $y)
    Start-Sleep -Seconds 1
    [MouseSimulator]::ClickAt($x, $y)
    Start-Sleep -Seconds 1
}

# 第一次点击操作
DoubleClick-AtPoint -x 489 -y 356
Start-Sleep -Seconds 2
# 初次尝试获取剪贴板内容
$clipContent = [System.Windows.Forms.Clipboard]::GetText()

# 剪贴板内容检测和处理
if (-not [string]::IsNullOrEmpty($clipContent)) {
    $clipContent | Out-File -FilePath "output.txt" -Encoding UTF8
    Write-Host "剪贴板内容已保存到 output.txt" -ForegroundColor Green
} 
else {
    # 剪贴板内容为空时进入重试流程
    Write-Host "初次获取无内容，等待2秒后重试..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    
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
