const express = require('express');
const axios = require('axios');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.raw({ type: 'application/octet-stream', limit: '50mb' }));

// 日志中间件
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
    next();
});

/**
 * 获取预处理参数
 * POST /preparams?batteryNo=xxxx
 * Body: token (plain text)
 */
app.post('/preparams', async (req, res) => {
    try {
        const { batteryNo } = req.query;
        const token = req.body;

        if (!batteryNo || !token) {
            return res.status(400).json({
                code: 400,
                message: '缺少必要参数：batteryNo 或 token'
            });
        }

        console.log(`[preparams] batteryNo: ${batteryNo}`);

        // 调用小哈的preparams接口
        const response = await axios.post(
            `https://10.11.20.83:8080/preparams?batteryNo=${batteryNo}`,
            token,
            {
                headers: {
                    'Content-Type': 'application/json'
                },
                timeout: 10000,
                httpsAgent: {
                    rejectUnauthorized: false // 忽略自签名证书错误
                }
            }
        );

        console.log('[preparams] 成功获取预处理参数');
        res.json(response.data);
    } catch (error) {
        console.error('[preparams] 错误:', error.message);
        res.status(500).json({
            code: 500,
            message: '获取预处理参数失败',
            error: error.message
        });
    }
});

/**
 * 获取电池数据
 * POST /battery
 * Body: { url, body, headers } 从preparams获取
 */
app.post('/battery', async (req, res) => {
    try {
        const { url, body, headers } = req.body;

        if (!url || !body) {
            return res.status(400).json({
                code: 400,
                message: '缺少必要参数：url 或 body'
            });
        }

        console.log(`[battery] 请求URL: ${url}`);

        // 调用小哈的API获取加密电池数据
        const response = await axios.post(
            url,
            body,
            {
                headers: headers || {
                    'Content-Type': 'application/json'
                },
                responseType: 'arraybuffer',
                timeout: 10000,
                httpsAgent: {
                    rejectUnauthorized: false
                }
            }
        );

        console.log('[battery] 成功获取加密数据，长度:', response.data.length);
        
        // 返回加密数据（base64编码便于传输）
        res.json({
            code: 200,
            data: Buffer.from(response.data).toString('base64'),
            contentType: response.headers['content-type']
        });
    } catch (error) {
        console.error('[battery] 错误:', error.message);
        res.status(500).json({
            code: 500,
            message: '获取电池数据失败',
            error: error.message
        });
    }
});

/**
 * 解码电池数据
 * POST /decode
 * Body: 加密的二进制数据或base64字符串
 */
app.post('/decode', async (req, res) => {
    try {
        let encryptedData;

        // 处理不同的输入格式
        if (typeof req.body === 'string') {
            // 如果是base64字符串，转换为Buffer
            encryptedData = Buffer.from(req.body, 'base64');
        } else if (Buffer.isBuffer(req.body)) {
            encryptedData = req.body;
        } else {
            return res.status(400).json({
                code: 400,
                message: '无效的请求体格式'
            });
        }

        console.log(`[decode] 收到加密数据，长度: ${encryptedData.length} bytes`);

        // 调用小哈的decode接口
        const response = await axios.post(
            'https://10.11.20.83:8080/decode',
            encryptedData,
            {
                headers: {
                    'Content-Type': 'application/octet-stream'
                },
                responseType: 'json',
                timeout: 10000,
                httpsAgent: {
                    rejectUnauthorized: false
                }
            }
        );

        console.log('[decode] 成功解码数据');
        res.json(response.data);
    } catch (error) {
        console.error('[decode] 错误:', error.message);
        res.status(500).json({
            code: 500,
            message: '解码失败',
            error: error.message
        });
    }
});

/**
 * 健康检查
 */
app.get('/health', (req, res) => {
    res.json({
        code: 200,
        message: '服务器正常运行',
        timestamp: new Date().toISOString()
    });
});

/**
 * 获取服务器信息
 */
app.get('/info', (req, res) => {
    res.json({
        code: 200,
        name: '小哈电池中转服务器',
        version: '1.0.0',
        uptime: process.uptime(),
        timestamp: new Date().toISOString()
    });
});

// 错误处理中间件
app.use((err, req, res, next) => {
    console.error('[ERROR]', err);
    res.status(500).json({
        code: 500,
        message: '服务器内部错误',
        error: err.message
    });
});

// 404处理
app.use((req, res) => {
    res.status(404).json({
        code: 404,
        message: '接口不存在'
    });
});

// 启动服务器
app.listen(PORT, () => {
    console.log(`\n========================================`);
    console.log(`小哈电池中转服务器已启动`);
    console.log(`Server running at http://localhost:${PORT}`);
    console.log(`========================================\n`);
    console.log('可用接口：');
    console.log(`  GET  /health          - 健康检查`);
    console.log(`  GET  /info            - 服务器信息`);
    console.log(`  POST /preparams       - 获取预处理参数`);
    console.log(`  POST /battery         - 获取电池数据`);
    console.log(`  POST /decode          - 解码电池数据`);
    console.log(`\n`);
});

module.exports = app;
