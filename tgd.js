const readline = require("readline");
const fs=require("fs").promises;
const { StringSession } = require("telegram/sessions");
const { TelegramClient, Api } = require("telegram");

const apiId = parseInt(process.env.TG_ID);
const apiHash = process.env.TG_HASH;
const stringSession = new StringSession(process.env.TG_SESSION);

// test.js
const { Builder, By, Key, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const path = require('path');


const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
});

const client = new TelegramClient(stringSession, apiId, apiHash, {
    connectionRetries: 3,
});

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
    filePath = __dirname+'/file.zip'; // 替换为你的本地文件绝对路径
    
    console.log('待上传文件路径:', filePath);

    // 5. 执行文件上传（核心：通过sendKeys传入绝对路径）
    await fileInputByClass.sendKeys(filePath);
    console.log('文件上传操作已触发');

    // 6. 验证上传结果（根据页面实际的成功提示调整）
    
      // 等待上传成功提示出现（示例：假设成功后显示".upload-success"元素）
      const successMsg = await driver.wait(
        until.elementLocated(By.className('main-title')),
        60000, // 上传可能较慢，适当延长等待时间
        '上传超时或失败'
      );
      console.log('文件上传成功！提示信息:', await successMsg.getText());
    
    
  } finally {
    await driver.quit();  // 关闭浏览器
  }
}

async function main() {
    try {
        await client.connect();
        console.log("已连接到 Telegram API");

        const messageUrl = 'https://t.me/whatNice/48';
        
        // 解析链接
        const urlParts = messageUrl.split('/');
        const username = urlParts[3];
        const messageId = parseInt(urlParts[4]);
        
        // 获取对话实体
        const entity = await client.getEntity(username);
        
        // 获取消息
        const result = await client.getMessages(entity, { ids: messageId });
        console.log("获取消息成功");
        
        // 下载并写入文件
        if (result.length > 0) {
            // 1. 先确认下载的 buffer 有效（避免空数据）
            const buffer = await client.downloadMedia(result[0], {
                progressCallback: (progress) => console.log("下载进度："+(progress/1000000)+"MB")
            });
            
            if (!buffer || buffer.length === 0) {
                console.error("下载失败：未获取到有效数据");
                return; // 数据为空时终止后续操作
            }
            
            // 2. 用 Promise 版本的 writeFile，确保 await 能等待写入完成
            await fs.writeFile("./file.zip", buffer); // 这里会等待写入完成
            console.log("文件写入成功：./file（大小：", buffer.length, "字节）"); // 打印大小验证
            
            await runTest();
            // 替换原来的 await setTimeout(...) 这行
            await new Promise(resolve => {
              setTimeout(() => {
                console.log("kkkkk");
                resolve(); // 等待结束后触发 resolve
              }, 60000);
            });

            
        } else {
            console.log("未找到目标消息");
        }

    } catch (error) {
        console.error("执行出错：", error); // 捕获所有错误（包括写入失败）
    } finally {
        if (client.connected) {
            await client.disconnect();
            console.log("已断开 Telegram 连接");
        }
        process.exit(0); // 此时写入已完成，再退出
    }
}

main().catch(err => {
    console.error("全局未捕获错误：", err);
    process.exit(1);
});
