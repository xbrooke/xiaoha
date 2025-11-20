#!/usr/bin/env node

/**
 * 小哈电池服务器 API 测试脚本
 * 使用方法: node test-api.js
 */

const http = require('http');

// 颜色定义（用于终端输出）
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m'
};

const BASE_URL = 'http://localhost:3000';

function log(color, message) {
  console.log(`${color}${message}${colors.reset}`);
}

function makeRequest(method, path, body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(BASE_URL + path);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Content-Type': method === 'POST' ? 'application/json' : 'application/json',
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          body: data
        });
      });
    });

    req.on('error', reject);

    if (body) {
      req.write(body);
    }
    req.end();
  });
}

async function runTests() {
  log(colors.cyan, '\n╔═══════════════════════════════════════════╗');
  log(colors.cyan, '║  🧪 小哈电池服务器 API 测试             ║');
  log(colors.cyan, '╚═══════════════════════════════════════════╝\n');

  // 测试 1: 健康检查
  log(colors.blue, '📍 测试 1: 健康检查 (/health)');
  try {
    const res = await makeRequest('GET', '/health');
    if (res.statusCode === 200) {
      log(colors.green, '   ✅ 服务器健康检查通过');
      log(colors.yellow, `   状态码: ${res.statusCode}`);
      log(colors.yellow, `   响应: ${res.body}`);
    } else {
      log(colors.red, `   ❌ 失败 (状态码: ${res.statusCode})`);
    }
  } catch (error) {
    log(colors.red, `   ❌ 错误: ${error.message}`);
    log(colors.red, '   💡 提示: 确保服务器正在运行 (npm run dev)\n');
    process.exit(1);
  }

  // 测试 2: Preparams 接口（缺少参数）
  log(colors.blue, '\n📍 测试 2: Preparams 接口 - 缺少参数验证');
  try {
    const res = await makeRequest('POST', '/preparams?batteryNo=test', '');
    if (res.statusCode === 400) {
      log(colors.green, '   ✅ 正确拒绝空 token');
      log(colors.yellow, `   状态码: ${res.statusCode}`);
      log(colors.yellow, `   响应: ${res.body}`);
    } else {
      log(colors.red, `   ❌ 意外状态码: ${res.statusCode}`);
    }
  } catch (error) {
    log(colors.red, `   ❌ 错误: ${error.message}`);
  }

  // 测试 3: Preparams 接口（缺少电池号）
  log(colors.blue, '\n📍 测试 3: Preparams 接口 - 缺少电池号验证');
  try {
    const res = await makeRequest('POST', '/preparams', 'test-token');
    if (res.statusCode === 400) {
      log(colors.green, '   ✅ 正确拒绝缺少的电池号');
      log(colors.yellow, `   状态码: ${res.statusCode}`);
      log(colors.yellow, `   响应: ${res.body}`);
    } else {
      log(colors.red, `   ❌ 意外状态码: ${res.statusCode}`);
    }
  } catch (error) {
    log(colors.red, `   ❌ 错误: ${error.message}`);
  }

  // 测试 4: 根路径
  log(colors.blue, '\n📍 测试 4: 根路径 (GET /)');
  try {
    const res = await makeRequest('GET', '/');
    if (res.statusCode === 200) {
      log(colors.green, '   ✅ 根路径可访问');
      log(colors.yellow, `   状态码: ${res.statusCode}`);
      const data = JSON.parse(res.body);
      log(colors.yellow, `   消息: ${data.message}`);
      log(colors.yellow, `   版本: ${data.version}`);
    } else {
      log(colors.red, `   ❌ 失败 (状态码: ${res.statusCode})`);
    }
  } catch (error) {
    log(colors.red, `   ❌ 错误: ${error.message}`);
  }

  log(colors.cyan, '\n╔═══════════════════════════════════════════╗');
  log(colors.cyan, '║         ✅ 基础测试完成                   ║');
  log(colors.cyan, '╚═══════════════════════════════════════════╝\n');

  log(colors.green, '📝 测试说明：');
  log(colors.yellow, '  1. 上述测试验证了服务器的基本功能');
  log(colors.yellow, '  2. 实际使用时，需要真实的 token 和电池号');
  log(colors.yellow, '  3. /preparams 会调用小哈官方 API');
  log(colors.yellow, '  4. /decode 需要从官方 API 获取的二进制数据\n');

  log(colors.bright, '💡 下一步：');
  log(colors.yellow, '  • 使用真实数据测试完整流程');
  log(colors.yellow, '  • 部署到 Netlify: git push origin main');
  log(colors.yellow, '  • 更新 Android/iOS 客户端的服务器地址\n');
}

// 运行测试
runTests().catch(error => {
  log(colors.red, `错误: ${error.message}`);
  process.exit(1);
});
