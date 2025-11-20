#!/bin/bash

# iOS 一键打包脚本
# 用法: bash build.sh [method] [output_dir]
# 方法: app-store (默认) | ad-hoc | enterprise | development | in-house

set -e

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 配置
SCHEME="小哈电池Widget"
CONFIGURATION="Release"
PROJECT_PATH="."
DERIVED_DATA_PATH="build/DerivedData"
ARCHIVE_PATH="build/archive.xcarchive"
EXPORT_METHOD="${1:-app-store}"
OUTPUT_DIR="${2:-.}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  iOS 一键打包脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 验证项目路径
if [ ! -f "*.xcodeproj" ]; then
    echo -e "${YELLOW}⚠️  警告：未在 Xcode 项目目录中${NC}"
    echo "请在包含 .xcodeproj 的目录中运行此脚本"
    exit 1
fi

# 显示配置信息
echo -e "${GREEN}📋 打包配置${NC}"
echo "  Scheme: $SCHEME"
echo "  Configuration: $CONFIGURATION"
echo "  Method: $EXPORT_METHOD"
echo "  Output: $OUTPUT_DIR"
echo ""

# 步骤 1: 清理构建目录
echo -e "${BLUE}[1/5]${NC} 清理旧构建文件..."
rm -rf build
mkdir -p build

# 步骤 2: 构建 Archive
echo -e "${BLUE}[2/5]${NC} 构建 Archive..."
echo "      这可能需要 2-5 分钟..."

xcodebuild archive \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -archivePath "$ARCHIVE_PATH" \
    -allowProvisioningUpdates \
    CODE_SIGN_STYLE=Automatic \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    DEVELOPMENT_TEAM="" 2>/dev/null

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Archive 构建失败${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Archive 构建成功${NC}"
echo ""

# 步骤 3: 检查 Archive
echo -e "${BLUE}[3/5]${NC} 检查 Archive 文件..."
ARCHIVE_SIZE=$(du -sh "$ARCHIVE_PATH" | cut -f1)
echo "      大小: $ARCHIVE_SIZE"

if [ ! -d "$ARCHIVE_PATH" ]; then
    echo -e "${RED}❌ Archive 文件不存在${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Archive 文件有效${NC}"
echo ""

# 步骤 4: 生成 IPA
echo -e "${BLUE}[4/5]${NC} 导出 IPA 文件..."
echo "      方法: $EXPORT_METHOD"

# 根据不同的分发方法创建 exportOptions
case $EXPORT_METHOD in
    app-store)
        cat > build/exportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>stripSwiftSymbols</key>
    <true/>
</dict>
</plist>
EOF
        ;;
    ad-hoc)
        cat > build/exportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
</dict>
</plist>
EOF
        ;;
    enterprise)
        cat > build/exportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>enterprise</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
</dict>
</plist>
EOF
        ;;
    development|in-house)
        cat > build/exportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF
        ;;
esac

xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "build/Payload" \
    -exportOptionsPlist "build/exportOptions.plist" \
    -allowProvisioningUpdates 2>/dev/null

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ IPA 导出失败${NC}"
    echo "      可能原因:"
    echo "      - 签名证书未配置"
    echo "      - Provisioning Profile 不匹配"
    echo "      - Team ID 未设置"
    exit 1
fi

echo -e "${GREEN}✓ IPA 导出成功${NC}"
echo ""

# 步骤 5: 复制到输出目录
echo -e "${BLUE}[5/5]${NC} 复制文件到输出目录..."

IPA_FILE=$(find build/Payload -name "*.ipa" -type f | head -1)

if [ -z "$IPA_FILE" ]; then
    echo -e "${RED}❌ 未找到 IPA 文件${NC}"
    exit 1
fi

cp "$IPA_FILE" "$OUTPUT_DIR/"
FINAL_IPA="$OUTPUT_DIR/$(basename "$IPA_FILE")"

echo -e "${GREEN}✓ 打包完成${NC}"
echo ""

# 显示结果
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 打包成功！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "📦 IPA 文件位置:"
echo "   $(cd "$OUTPUT_DIR" && pwd)/$(basename "$FINAL_IPA")"
echo ""
echo -e "📊 文件信息:"
echo "   大小: $(du -h "$FINAL_IPA" | cut -f1)"
echo "   类型: $(file "$FINAL_IPA" | cut -d: -f2)"
echo ""
echo -e "下一步:"
echo "   • TestFlight: 上传到 App Store Connect"
echo "   • 手机安装: 通过 Xcode 连接设备后安装"
echo "   • 分发: 发送 .ipa 文件给其他人"
echo ""
