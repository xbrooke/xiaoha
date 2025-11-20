#!/usr/bin/env node

const axios = require('axios');

const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';
const BATTERY_NO = '8895016218';
const TOKEN = '6ZQ5WLr+tnwhuYPF/IFlq1vF2gYvCpBFdi6MqYdc4451wTt3VjId2NzKV3ur0xR+mVE/4lY8ixaipz9MKOJ7KEBAM4/uqZyRxC2FBHE8zunNEddjBZkR9lUfG/C8LP6alxP+G4rJRuFqsFBS+v4N5azNMiOnt1FE64AEhHrlPKxxss7teCdRJDDeUYcZrWi0LKfaC0+jcGg+66eXTyxzO0tWuY/jEtaCSzqAXgMHVE14wKoK9piHSJZCz5WPoaq6agxawtmZPeI/f/OyflBIq05+rSrecOB+55S3ZxPhHoWp1UNcrCeFwfVbQKKURJp5G1F+CYAFA0Np9Xu4bYa+sD08uSivJHCzOfrjwgKlJ6BxNqiLuZWHD2trbcSctgh0+wn/BaDNI88NCAkIwR3l9A==';

console.log('🧪 开始API测试...\n');
console.log(`📍 服务器地址: ${BASE_URL}`);
console.log(`🔋 电池编号: ${BATTERY_NO}\n`);

async function test() {
    try {
        // 测试1: 健康检查
        console.log('✏️  测试1: 健康检查 (/health)');
        const healthRes = await axios.get(`${BASE_URL}/health`);
        console.log('✅ 成功');
        console.log(`   状态: ${healthRes.data.status}\n`);

        // 测试2: 获取预处理参数
        console.log('✏️  测试2: 获取预处理参数 (/preparams)');
        const preparamsRes = await axios.post(
            `${BASE_URL}/preparams?batteryNo=${BATTERY_NO}`,
            TOKEN,
            {
                headers: {
                    'Content-Type': 'text/plain',
                },
                timeout: 10000,
            }
        );
        console.log('✅ 成功');
        console.log(`   响应结构:`, Object.keys(preparamsRes.data).join(', '));
        
        if (preparamsRes.data.data) {
            const { url, body, headers } = preparamsRes.data.data;
            console.log(`   官方API URL: ${url ? url.substring(0, 50) + '...' : '未知'}`);
            console.log(`   Body长度: ${body ? body.length : 0} 字符`);
            console.log(`   Headers数量: ${headers ? Object.keys(headers).length : 0}\n`);
        }

        console.log('✅ 所有测试通过！');
        console.log('\n现在可以在widget.js中使用此服务器地址。');

    } catch (error) {
        console.error('❌ 测试失败');
        
        if (error.response) {
            console.error(`   状态码: ${error.response.status}`);
            console.error(`   错误信息: ${error.response.data?.message || error.response.statusText}`);
        } else if (error.code === 'ECONNREFUSED') {
            console.error('   无法连接到服务器，确保已运行: npm start');
        } else if (error.code === 'ENOTFOUND') {
            console.error(`   DNS解析失败: ${error.hostname}`);
        } else {
            console.error(`   错误: ${error.message}`);
        }
        
        process.exit(1);
    }
}

test();
