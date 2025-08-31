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

Invoke-WebRequest -Uri "https://download.anydesk.com/AnyDesk.exe" -OutFile "C:\Temp\AnyDesk.exe"

# 执行静默安装（使用超时控制）
Start-Process -FilePath "C:\Temp\AnyDesk.exe" -ArgumentList '--install "C:\ProgramData\AnyDesk" --start-with-win --silent' -Wait

# 设置密码
echo "password111" | & "C:\ProgramData\AnyDesk\AnyDesk.exe" --set-password

# 3. 尝试启动程序
& "C:\ProgramData\AnyDesk\AnyDesk.exe"

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
