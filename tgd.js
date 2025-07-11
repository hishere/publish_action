// test.js
const { Builder, By, Key, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');

async function runTest() {
  // 配置 Chrome 无头模式
  const options = new chrome.Options()
    .addArguments('--headless=new')  // 无头模式（必填）
    .addArguments('--disable-gpu')
    .addArguments('--no-sandbox');   // 避免权限问题

  // 初始化 WebDriver（关联 ChromeDriver）
  const driver = await new Builder()
    .forBrowser('chrome')
    .setChromeOptions(options)
    .build();

  try {
    // 访问测试页面并执行操作
    await driver.get("https://easylink.cc/");
    const pageTitle = await driver.getTitle();
    console.log('页面标题（title）:', pageTitle);
    
    await driver.executeScript(`
      // 设置普通字符串
      localStorage.setItem('token', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlvbmlkIjoib3BxTHZqdFZ2M1lKLWxQYVNqUjNzeUhvcmI2OCIsImlhdCI6MTc1MjIzNTU2MSwiZXhwIjoxNzU3NDE5NTYxfQ.KTitdFi-iAbJvqbM8tktJCGuhi_2YrNgWOqIdRIhFxM');
      // 设置对象（需用 JSON.stringify 转换为字符串）
      localStorage.setItem('userInfo', JSON.stringify({ id: 1, name: '张三' }));
    `);
    
    await driver.navigate().refresh();
    console.log('页面已刷新');
    // 2. 截图（返回 Base64 编码的图片数据）
    const screenshotBase64 = await driver.takeScreenshot();

    // 3. 准备保存路径（创建 screenshots 目录，避免文件不存在错误）
    const screenshotPath = "./screenshot.png";

    // 5. 将 Base64 数据写入文件（Base64 解码后保存为 PNG）
    await fs.writeFile(screenshotPath, screenshotBase64, 'base64');
    console.log(`截图已保存至: ${screenshotPath}`);
  } finally {
    await driver.quit();  // 关闭浏览器
  }
}

runTest();
