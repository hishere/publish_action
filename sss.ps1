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

# 步骤2: 启动 ToDesk 并等待
Start-Process -FilePath ".\ask.exe"
Start-Sleep -Seconds 9

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
[MouseSimulator]::ClickAt(646, 547)
Start-Sleep -Seconds 2
[MouseSimulator]::ClickAt(700, 618)
Start-Sleep -Seconds 15
