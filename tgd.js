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
    await driver.get(process.env.TEST_URL || 'https://example.com');
    await driver.findElement(By.tagName('h1')).getText().then(text => {
      console.log('页面标题:', text);
    });
  } finally {
    await driver.quit();  // 关闭浏览器
  }
}

runTest();
