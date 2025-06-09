; ====== 初始化设置 ======
#NoTrayIcon              ; 隐藏托盘图标
#SingleInstance Force    ; 强制单实例运行
SetTitleMatchMode 2      ; 窗口标题模糊匹配
CoordMode "Mouse", "Screen"  ; 鼠标坐标基于整个屏幕[10](@ref)

; ====== 主执行流程 ======
^!s::  ; 设置热键 Ctrl+Alt+S 触发（可按需修改）
{
    ; 第一阶段：显示桌面
    Send "#d"            ; Win+D 显示桌面[1,2](@ref)
    Sleep 1000           ; 等待1秒

    ; 第二阶段：启动程序
    Run ".\ask.exe"      ; 启动当前目录的ask.exe[4](@ref)
    Sleep 5000           ; 等待5秒确保加载[10](@ref)

    ; 第三阶段：模拟鼠标操作
    MouseMove 646, 547   ; 移动鼠标到坐标(646,547)
    Click                ; 左键单击[9](@ref)
    Sleep 2000           ; 等待2秒
    
    MouseMove 700, 618   ; 移动到新坐标(700,618)
    Click                ; 左键单击
    Sleep 15000          ; 等待15秒
}
