const axios = require('axios');

/**
 * Netlify Functions 处理函数
 * 用于在 Netlify 上部署 Express 应用
 */

/**
 * 获取预处理参数
 */
exports.preparams = async (event) => {
  try {
    const { batteryNo } = event.queryStringParameters || {};
    const token = event.body;

    if (!batteryNo) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: '缺少电池编号' })
      };
    }

    if (!token) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: '缺少token' })
      };
    }

    console.log(`[preparams] 请求 - batteryNo: ${batteryNo}`);

    // 调用小哈官方接口
    const preparamsUrl = 'https://app.linkof.link/api/battery/preparams';
    
    const response = await axios.post(preparamsUrl, token, {
      params: { batteryNo },
      headers: {
        'Content-Type': 'text/plain'
      },
      timeout: 10000
    });

    console.log('[preparams] 响应成功');

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify(response.data)
    };
  } catch (error) {
    console.error('[preparams] 错误:', error.message);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({ 
        error: '获取预处理参数失败',
        detail: error.message 
      })
    };
  }
};

/**
 * 解码电池数据
 */
exports.decode = async (event) => {
  try {
    // 获取二进制数据
    const encryptedData = event.isBase64Encoded 
      ? Buffer.from(event.body, 'base64') 
      : Buffer.from(event.body);

    if (!encryptedData || encryptedData.length === 0) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: '缺少加密数据' })
      };
    }

    console.log(`[decode] 请求 - 数据长度: ${encryptedData.length} bytes`);

    // 调用小哈官方解码接口
    const decodeUrl = 'https://app.linkof.link/api/battery/decode';

    const response = await axios.post(decodeUrl, encryptedData, {
      headers: {
        'Content-Type': 'application/octet-stream'
      },
      timeout: 10000,
      responseType: 'json'
    });

    console.log('[decode] 响应成功');

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify(response.data)
    };
  } catch (error) {
    console.error('[decode] 错误:', error.message);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({ 
        error: '解码电池数据失败',
        detail: error.message 
      })
    };
  }
};

/**
 * 健康检查
 */
exports.health = async (event) => {
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify({ status: 'healthy' })
  };
};
