var readline = require("readline");
const {StringSession} = require("telegram/sessions");
const {TelegramClient, Api} = require("telegram");

const apiId = process.env.TG_ID;
const apiHash = process.env.TG_HASH;
const stringSession = new StringSession(process.env.TG_SESSION); // fill this later with the value from session.save()

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
});


console.log("apiId:", apiId ? "已设置" : "未设置");
console.log("apiHash:", apiHash ? "已设置" : "未设置");
console.log("stringSession:", stringSession.save() ? "已加9载" : "未加载");
