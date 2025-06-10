# 修改后的截图脚本（兼容无界面环境）
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 1. 直接捕获屏幕（不依赖剪贴板）
$screenBounds = [System.Windows.Forms.SystemInformation]::VirtualScreen
$bitmap = New-Object System.Drawing.Bitmap $screenBounds.Width, $screenBounds.Height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

# 2. 使用CopyFromScreen直接复制屏幕内容
$graphics.CopyFromScreen(
    $screenBounds.Location, 
    [System.Drawing.Point]::Empty, 
    $screenBounds.Size
)

# 3. 释放资源并保存
$graphics.Dispose()
$screenshotPath = "$env:RUNNER_TEMP\screenshot.png"
$bitmap.Save($screenshotPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bitmap.Dispose()

# 4. 设置环境变量
echo "SCREENSHOT_PATH=$screenshotPath" >> $env:GITHUB_ENV
