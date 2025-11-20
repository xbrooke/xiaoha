#!/bin/bash

# iOS 版本快速测试脚本
# 用法: bash test_ios.sh

echo "🔍 小哈电池Widget iOS版本 - 快速测试"
echo "========================================"
echo ""

# 配置
BATTERY_NO="8903115649"  # 替换为你的电池编号
TOKEN="your_token_here"  # 替换为你的Token
BASE_URL="https://xiaoha.linkof.link"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查必要的工具
check_requirements() {
    echo "📦 检查环境..."
    
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}✗ curl 未安装${NC}"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}✗ jq 未安装 (用于JSON解析)${NC}"
        echo "  macOS: brew install jq"
        exit 1
    fi
    
    echo -e "${GREEN}✓ 环境检查完成${NC}"
}

# 测试步骤1：获取预处理参数
test_preparams() {
    echo ""
    echo "📋 步骤1: 获取预处理参数..."
    
    RESPONSE=$(curl -s -X POST \
        "${BASE_URL}/preparams?batteryNo=${BATTERY_NO}" \
        -H "Content-Type: text/plain" \
        -d "${TOKEN}")
    
    echo "响应: $RESPONSE"
    
    # 检查响应
    if echo "$RESPONSE" | jq -e '.data' > /dev/null 2>&1; then
        echo -e "${GREEN}✓ 获取预处理参数成功${NC}"
        echo "$RESPONSE"
        return 0
    else
        echo -e "${RED}✗ 获取预处理参数失败${NC}"
        return 1
    fi
}

# 测试步骤2：获取电池数据
test_battery_data() {
    echo ""
    echo "⚡ 步骤2: 获取电池数据..."
    
    # 需要从步骤1的结果中提取 URL、Body 和 Headers
    # 这里简化处理，实际使用时需要解析步骤1的结果
    
    echo -e "${YELLOW}ℹ  此步骤需要步骤1的响应数据${NC}"
}

# 测试步骤3：解码数据
test_decode() {
    echo ""
    echo "🔓 步骤3: 解码电池数据..."
    
    echo -e "${YELLOW}ℹ  此步骤需要步骤2的响应数据${NC}"
}

# 网络连接测试
test_network() {
    echo ""
    echo "🌐 网络连接测试..."
    
    if ping -c 1 xiaoha.linkof.link &> /dev/null; then
        echo -e "${GREEN}✓ 服务器可访问${NC}"
    else
        echo -e "${RED}✗ 无法访问服务器${NC}"
        return 1
    fi
}

# 主测试流程
main() {
    check_requirements
    test_network
    
    # 获取Token
    if [ "$TOKEN" = "your_token_here" ]; then
        echo ""
        echo -e "${YELLOW}⚠️  注意: 请在脚本中设置 TOKEN 变量${NC}"
        echo "从小哈租电小程序中通过抓包获取 Token，然后更新脚本中的 TOKEN 变量。"
        return 1
    fi
    
    test_preparams
    
    # 完整API测试 URL
    echo ""
    echo "📚 Postman 测试链接:"
    echo ""
    echo "1️⃣  获取预处理参数:"
    echo "   POST: ${BASE_URL}/preparams?batteryNo=${BATTERY_NO}"
    echo "   Headers: Content-Type: text/plain"
    echo "   Body: [YOUR_TOKEN]"
    echo ""
    echo "2️⃣  获取电池数据:"
    echo "   POST: [来自步骤1的URL]"
    echo "   Headers: [来自步骤1的headers]"
    echo "   Body: [来自步骤1的body]"
    echo ""
    echo "3️⃣  解码电池数据:"
    echo "   POST: ${BASE_URL}/decode"
    echo "   Headers: Content-Type: application/octet-stream"
    echo "   Body: [来自步骤2的响应数据]"
    echo ""
}

# 运行测试
main
