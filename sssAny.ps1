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


Start-Sleep -Seconds 1


# 设置密码
echo "password111" | & "C:\ProgramData\AnyDesk\AnyDesk.exe" --set-password


Start-Sleep -Seconds 1


# 3. 尝试启动程序
Start-Process -FilePath "C:\ProgramData\AnyDesk\AnyDesk.exe" -PassThru

Start-Sleep -Seconds 14

# 使用 --get-id 参数获取 AnyDesk ID[1](@ref)
#$AnyDeskID = & "C:\ProgramData\AnyDesk\AnyDesk.exe" --get-id
$AnyDeskID="xxx"
# 检查是否成功获取到 ID，如果获取不到则写入 "empty"
if ([string]::IsNullOrWhiteSpace($AnyDeskID)) {
    "empty" | Out-File -FilePath "output.txt" -Encoding UTF8
    Write-Host "未获取到 AnyDesk ID，已写入 'empty' 到 output.txt" -ForegroundColor Yellow
} else {
    $AnyDeskID | Out-File -FilePath "output.txt" -Encoding UTF8
    Write-Host "AnyDesk ID 已获取并写入 output.txt: $AnyDeskID" -ForegroundColor Green
}

Start-Sleep -Seconds 1