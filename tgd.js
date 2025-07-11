// test.js
const { Builder, By, Key, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const path = require('path');


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
    
    // 方法1：使用 By.className() 定位（仅适用于单个class名称，无空格）
    const fileInputByClass = await driver.wait(
      until.elementLocated(By.className('file-input')), // 直接传入class名称
      10000,
      '未找到class为file-input的元素（方法1）'
    );
    console.log('方法1：成功找到class为file-input的元素');
    
    // 当前目录（src/）的绝对路径
    const currentDirAbsPath = __dirname;
    console.log(currentDirAbsPath);
    filePath = __dirname+'./package.json'; // 替换为你的本地文件绝对路径
    
    console.log('待上传文件路径:', filePath);

    // 5. 执行文件上传（核心：通过sendKeys传入绝对路径）
    await fileInputByClass.sendKeys(filePath);
    console.log('文件上传操作已触发');

    // 6. 验证上传结果（根据页面实际的成功提示调整）
    
      // 等待上传成功提示出现（示例：假设成功后显示".upload-success"元素）
      const successMsg = await driver.wait(
        until.elementLocated(By.className('main-title')),
        5000, // 上传可能较慢，适当延长等待时间
        '上传超时或失败'
      );
      console.log('文件上传成功！提示信息:', await successMsg.getText());
    
    
  } finally {
    await driver.quit();  // 关闭浏览器
  }
}

runTest();
