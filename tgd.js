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
    try {
        const result = await client.getMessages(messageUrl);
        console.log("re2222:"+result);

        if (!message.length || !message[0].media) {
            throw new Error("Message does not contain a file or message not found");
        }

        const fileName = await getFileNameFromMessage(message[0]);
        const downloadPath = `./downloads/${fileName}`;
        await client.downloadMedia(message[0].media, {
            progress: (current, total) => {
                const progress = (current / total) * 100;
                console.log(`Download progress: ${progress.toFixed(2)}%`);
            },
            save: downloadPath,
        });

        console.log(`File downloaded successfully to: ${downloadPath}`);
        recordDownloadOperation(messageUrl, fileName, downloadPath);
    } catch (error) {
        console.error("Error occurred during file download:", error.message);
        recordDownloadError(messageUrl, error.message);
    } finally {
        setTimeout(function () {
            process.exit(0);
        }, 12000);
    }
})();

function parseMessageUrl(url) {
    const pattern = /https?:\/\/t\.me\/([^\/]+)\/(\d+)(\?single)?/;
    const match = url.match(pattern);
    return match ? { channel: match[1], messageId: parseInt(match[2]) } : { channel: null, messageId: null };
}

async function getFileNameFromMessage(message) {
    if (message.media.document) {
        return message.media.document.attributes.find(attr => attr instanceof Api.DocumentAttributeFilename).fileName;
    } else if (message.media.photo) {
        return `photo_${message.media.photo.id}.jpg`;
    } else {
        return "unknown_file";
    }
}

function recordDownloadOperation(messageUrl, fileName, filePath) {
    const downloadLog = {
        timestamp: new Date().toISOString(),
        messageUrl: messageUrl,
        fileName: fileName,
        filePath: filePath,
        status: "success",
    };
    console.log("Download Log:", JSON.stringify(downloadLog));
}

function recordDownloadError(messageUrl, errorMessage) {
    const errorLog = {
        timestamp: new Date().toISOString(),
        messageUrl: messageUrl,
        error: errorMessage,
        status: "failed",
    };
    console.error("Download Error Log:", JSON.stringify(errorLog));
}
