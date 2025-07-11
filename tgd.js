const readline = require("readline");
const { StringSession } = require("telegram/sessions");
const { TelegramClient, Api } = require("telegram");

const apiId = parseInt(process.env.TG_ID, 10);
const apiHash = process.env.TG_HASH;
const stringSession = new StringSession(process.env.TG_SESSION);

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
});

const client = new TelegramClient(stringSession, apiId, apiHash, {
    connectionRetries: 3,
});

(async () => {
    console.log("Loading interactive example...");
    await client.connect();
    console.log("Connected to Telegram API");

    const messageUrl="https://t.me/listenNice/408";
    
    const result = await client.getMessages(messageUrl);
    console.log("re2222:"+result);

        
})();