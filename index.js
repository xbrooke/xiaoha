const express = require('express');
const axios = require('axios');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();

// 中间件
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.raw({ type: 'application/octet-stream', limit: '10mb' }));
app.use(bodyParser.text({ type: 'text/plain' }));

// 配置
const PREPARAMS_URL = 'https://d.sosun.cc/preparams';
const DECODE_URL = 'https://d.sosun.cc/decode';

// 健康检查
app.get('/health', (req, res) => {
    res.json({ status: 'healthy' });
});

// 首页
app.get('/', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>小哈电池 API 中转服务</title>
            <style>
                body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
                .api { background: #f5f5f5; padding: 15px; margin: 10px 0; border-radius: 5px; }
                code { background: #e0e0e0; padding: 2px 5px; border-radius: 3px; }
            </style>
        </head>
        <body>
            <h1>🔋 小哈电池 API 中转服务</h1>
            <p>该服务为小哈电池小组件提供 API 中转功能。</p>
            
            <div class="api">
                <h3>POST /preparams</h3>
                <p>获取预处理参数</p>
                <code>Content-Type: text/plain</code><br>
                Body: token
            </div>
            
            <div class="api">
                <h3>POST /decode</h3>
                <p>解码电池数据</p>
                <code>Content-Type: application/octet-stream</code><br>
                Body: 加密的二进制数据
            </div>
            
            <div class="api">
                <h3>GET /health</h3>
                <p>健康检查</p>
            </div>
            
            <p style="color: #666; margin-top: 30px; font-size: 12px;">
                v1.0.0 | Powered by 小哈电池
            </p>
        </body>
        </html>
    `);
});

// 转发 /preparams 请求
app.post('/preparams', async (req, res) => {
    try {
        const batteryNo = req.query.batteryNo;
        const token = req.body;

        console.log(`[preparams] batteryNo: ${batteryNo}, token length: ${token ? token.length : 0}`);

        if (!batteryNo || !token) {
            return res.status(400).json({ error: '缺少必要参数' });
        }

        // 转发到原服务器
        const response = await axios.post(
            `${PREPARAMS_URL}?batteryNo=${batteryNo}`,
            token,
            {
                headers: {
                    'Content-Type': 'text/plain',
                },
                timeout: 10000,
            }
        );

        res.json(response.data);
    } catch (error) {
        console.error('[preparams] Error:', error.message);
        res.status(500).json({
            error: '获取预处理参数失败',
            message: error.message,
        });
    }
});

// 转发 /decode 请求
app.post('/decode', async (req, res) => {
    try {
        const encryptedData = req.body;

        console.log(`[decode] data length: ${encryptedData ? encryptedData.length : 0}`);

        if (!encryptedData) {
            return res.status(400).json({ error: '缺少加密数据' });
        }

        // 转发到原服务器（保持二进制格式）
        const response = await axios.post(DECODE_URL, encryptedData, {
            headers: {
                'Content-Type': 'application/octet-stream',
            },
            timeout: 10000,
            responseType: 'arraybuffer',
        });

        // 解析响应
        const responseText = response.data.toString('utf-8');
        const responseJson = JSON.parse(responseText);

        res.json(responseJson);
    } catch (error) {
        console.error('[decode] Error:', error.message);
        res.status(500).json({
            error: '解码失败',
            message: error.message,
        });
    }
});

// 错误处理
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({
        error: '服务器错误',
        message: err.message,
    });
});

// 启动服务器
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`✅ 服务器运行在 http://localhost:${PORT}`);
    console.log(`📍 /health - 健康检查`);
    console.log(`📍 POST /preparams?batteryNo=xxx - 获取预处理参数`);
    console.log(`📍 POST /decode - 解码电池数据`);
});

module.exports = app;
