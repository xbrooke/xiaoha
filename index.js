const express = require('express');
const axios = require('axios');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.text({ type: 'text/plain' }));
app.use(bodyParser.raw({ type: 'application/octet-stream', limit: '10mb' }));

// 健康检查
app.get('/', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: '小哈电池服务器运行中',
    version: '1.0.0'
  });
});

/**
 * 步骤1: 获取预处理参数
 * POST /preparams?batteryNo={电池编号}
 * Body: token
 */
app.post('/preparams', async (req, res) => {
  try {
    const { batteryNo } = req.query;
    const token = req.body;

    if (!batteryNo) {
      return res.status(400).json({ error: '缺少电池编号' });
    }

    if (!token) {
      return res.status(400).json({ error: '缺少token' });
    }

    console.log(`[preparams] 请求 - batteryNo: ${batteryNo}`);

    // 调用小哈官方预处理接口
    // 这里需要替换为实际的小哈预处理接口地址
    const preparamsUrl = 'https://app.linkof.link/api/battery/preparams';
    
    const response = await axios.post(preparamsUrl, token, {
      params: { batteryNo },
      headers: {
        'Content-Type': 'text/plain'
      },
      timeout: 10000
    });

    console.log('[preparams] 响应成功');

    // 返回响应给客户端
    res.json(response.data);
  } catch (error) {
    console.error('[preparams] 错误:', error.message);
    res.status(500).json({ 
      error: '获取预处理参数失败',
      detail: error.message 
    });
  }
});

/**
 * 步骤3: 解码电池数据
 * POST /decode
 * Body: 二进制加密数据
 */
app.post('/decode', async (req, res) => {
  try {
    const encryptedData = req.body;

    if (!encryptedData || encryptedData.length === 0) {
      return res.status(400).json({ error: '缺少加密数据' });
    }

    console.log(`[decode] 请求 - 数据长度: ${encryptedData.length} bytes`);

    // 调用小哈官方解码接口
    // 这里需要替换为实际的小哈解码接口地址
    const decodeUrl = 'https://app.linkof.link/api/battery/decode';

    const response = await axios.post(decodeUrl, encryptedData, {
      headers: {
        'Content-Type': 'application/octet-stream'
      },
      timeout: 10000,
      responseType: 'json'
    });

    console.log('[decode] 响应成功');

    // 返回解码结果
    res.json(response.data);
  } catch (error) {
    console.error('[decode] 错误:', error.message);
    res.status(500).json({ 
      error: '解码电池数据失败',
      detail: error.message 
    });
  }
});

/**
 * 健康检查接口
 */
app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

// 错误处理
app.use((err, req, res, next) => {
  console.error('错误:', err);
  res.status(500).json({ 
    error: '服务器内部错误',
    detail: err.message 
  });
});

app.listen(PORT, () => {
  console.log(`小哈电池服务器运行在端口 ${PORT}`);
  console.log(`访问 http://localhost:${PORT} 查看状态`);
});
