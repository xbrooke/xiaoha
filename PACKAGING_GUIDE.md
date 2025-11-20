# iOS 版本打包指南

## 🎯 打包目标

本指南涵盖以下打包方式：
- ✅ TestFlight 内部测试版本
- ✅ Ad Hoc 企业分发
- ✅ App Store 官方发布
- ✅ Development 开发调试

---

## 📋 前置准备

### 1. Apple Developer 账号

- [ ] 已加入 Apple Developer Program ($99/年)
- [ ] 账号处于有效状态
- [ ] 有权限管理证书和描述符

### 2. 开发工具

- [ ] Xcode 14.0+ 已安装
- [ ] 最新版本的 Xcode Command Line Tools
- [ ] macOS 12.0+ 系统

### 3. 项目信息准备

```
应用名称：小哈电池Widget
Bundle ID：com.yourcompany.batterywidget
版本号：1.0.0
构建号：1
最低 iOS 版本：16.0
```

---

## 🔑 第一步：获取证书和描述符

### 1.1 创建 App ID

```
1. 登录 Apple Developer (developer.apple.com)
2. 导航到 Certificates, Identifiers & Profiles
3. 点击 Identifiers → 添加新的 Identifier
4. 选择 App IDs
5. 输入：
   - App Name：小哈电池Widget
   - Bundle ID：com.yourcompany.batterywidget
   - Capabilities：勾选需要的功能
6. 保存
```

### 1.2 创建证书

**Development 证书**（用于开发和测试）

```
1. Certificates → 点击 "+"
2. 选择 "iOS App Development"
3. 按照提示生成证书请求 (CSR)
4. 上传并下载证书
5. 双击在 Keychain 中安装
```

**Distribution 证书**（用于发布）

```
1. Certificates → 点击 "+"
2. 选择 "iOS Distribution"
3. 按照提示生成 CSR
4. 上传并下载证书
5. 双击在 Keychain 中安装
```

### 1.3 创建描述符 (Provisioning Profile)

**开发描述符**

```
1. Provisioning Profiles → Development → "+"
2. 选择应用和证书
3. 选择所有开发设备
4. 下载并安装
```

**TestFlight 描述符**

```
1. Provisioning Profiles → Ad Hoc → "+"
2. 选择应用和 Distribution 证书
3. 选择要测试的设备
4. 下载并安装
```

**App Store 描述符**

```
1. Provisioning Profiles → App Store → "+"
2. 选择应用和 Distribution 证书
3. 下载并安装
```

---

## 🔧 第二步：Xcode 签名配置

### 2.1 选择 Team

```
1. 打开 Xcode 项目
2. 选择 Project → Signing & Capabilities
3. 主应用 Target：
   - Team：选择你的 Apple Developer Team
   - Signing Certificate：选择 Development/Distribution
   - Provisioning Profile：自动选择
4. Widget Extension Target：
   - 重复上述步骤
```

### 2.2 验证签名

```
1. Product → Scheme → Edit Scheme
2. Build 配置选择：Debug 或 Release
3. 确保所有 Target 的签名都正确
```

---

## 📦 第三步：版本配置

### 3.1 更新版本号

**主应用版本**

```
1. 选择 Project → General
2. Identity 部分：
   - Bundle Identifier：com.yourcompany.batterywidget
   - Version：1.0.0
   - Build：1
3. Deployment Info：
   - Minimum Deployments：iOS 16.0
```

**Widget Extension 版本**

```
1. 选择 Widget Extension Target → General
2. 同样更新 Version 和 Build
```

### 3.2 构建设置优化

```
1. Build Settings 搜索：
   - Deployment Target：16.0
   - Code Sign Identity：iPhone Distribution
   - Provisioning Profile：选择 App Store
   - Code Sign Style：Automatic 或 Manual
```

---

## 🏗️ 第四步：构建应用

### 4.1 Archive 构建

**使用 Xcode GUI**

```
1. 选择 Scheme：小哈电池Widget
2. 选择任意 iOS 设备（不要选模拟器）
3. Product → Archive
4. 等待构建完成（通常 2-5 分钟）
5. 完成后自动打开 Archives 窗口
```

**使用命令行**

```bash
# Archive 构建
xcodebuild archive \
  -scheme "小哈电池Widget" \
  -configuration Release \
  -derivedDataPath build \
  -archivePath "build/小哈电池Widget.xcarchive"

# 查看构建输出
open "build/小哈电池Widget.xcarchive"
```

### 4.2 检查 Archive

```
1. 在 Archives 窗口中看到新构建的 Archive
2. 右键 → "Show in Finder" 验证文件大小合理
3. 通常主应用 + Widget 总大小在 10-50 MB
```

---

## 📤 第五步：分发方式选择

### 方式 1️⃣：TestFlight（推荐测试）

**步骤**

```
1. 在 Archives 窗口选择 Archive
2. 点击 "Distribute App"
3. 选择 Distribution Method：
   - TestFlight and App Store
4. 选择签名证书和描述符
5. 点击 "Next" 并上传
6. 等待处理完成（通常几分钟）
```

**添加测试人员**

```
1. 打开 App Store Connect (appstoreconnect.apple.com)
2. 选择应用 → TestFlight
3. 构建版本 → 添加测试人员
4. 输入测试者的 Apple ID
5. 发送邀请链接
```

**测试人员操作**

```
1. 收到邀请邮件
2. 点击链接进入 TestFlight 应用
3. 搜索应用名称
4. 点击 "Install" 开始测试
```

### 方式 2️⃣：Ad Hoc（企业分发）

**步骤**

```
1. Archives 窗口 → Distribute App
2. 选择 Distribution Method：Ad Hoc
3. 选择设备和证书
4. 导出 .ipa 文件
5. 用户通过 Apple Configurator 2 安装
```

**用户安装步骤**

```
1. 在 Mac 上用 Apple Configurator 2 打开 .ipa
2. 或直接用 Xcode 连接 iPhone
3. 选择 Window → Devices and Simulators
4. 拖动 .ipa 文件到设备
```

### 方式 3️⃣：App Store（官方发布）

**步骤**

```
1. Archives 窗口 → Distribute App
2. 选择 Distribution Method：App Store
3. 选择上传方式（自动或手动）
4. 完成签名和上传
5. 等待处理
```

**提交审核**

```
1. App Store Connect → 应用
2. 选择新构建版本
3. 版本信息 → 输入发布信息
4. 点击 "Submit for Review"
5. 等待苹果审核（1-3天）
```

---

## 🔍 第六步：构建验证

### 6.1 验证构建大小

```
合理的大小范围：
- App Bundle：5-20 MB
- Widget Extension：2-5 MB
- 总大小：10-50 MB

如果超过 200 MB 可能有问题
```

### 6.2 验证依赖

```
1. 在 Xcode 中检查 Build Phases
2. 确保所有必要的框架都包含
3. 没有未引用的大文件
```

### 6.3 符号表验证

```
1. 打开 Archive → Show in Finder
2. 右键 → Show Package Contents
3. 检查是否存在 .dSYM 文件（用于崩溃日志）
```

---

## 🐛 常见打包问题

### 问题 1：签名错误

```
症状：error: The signing identity "..."
原因：证书过期或选择错误
解决：
1. 检查 Apple Developer 中的证书是否有效
2. 删除 Xcode 的缓存：rm -rf ~/Library/Developer/Xcode/DerivedData
3. 在 Keychain 中确认证书已安装
4. 重新选择签名证书
```

### 问题 2：描述符不匹配

```
症状：No provisioning profiles found
原因：Provisioning Profile 与应用不匹配
解决：
1. 检查 Bundle ID 是否完全匹配
2. 在 Apple Developer 中重新创建描述符
3. 下载并安装到 Xcode
4. 清空 Xcode 缓存后重试
```

### 问题 3：Widget 签名失败

```
症状：Widget Extension 签名错误
原因：Widget 使用了不支持的 API
解决：
1. 检查 Widget 代码中的 API 兼容性
2. 确保 Widget Target 的最低版本是 16.0
3. 验证 Widget 是否正确链接到主应用
```

### 问题 4：Archive 过大

```
症状：构建包超过 200 MB
原因：包含了调试符号或大文件
解决：
1. Build Settings 搜索 "Strip"
2. 设置 Strip Linked Product：Yes
3. 设置 Strip Style：Non-Global Symbols
4. 重新构建
```

### 问题 5：TestFlight 上传失败

```
症状：Upload 失败或卡住
原因：网络问题或构建配置
解决：
1. 检查网络连接
2. 尝试用命令行上传：
   xcrun altool --upload-app --file app.ipa \
   --type ios --username apple@example.com \
   --password @keychain:password
3. 或用 App Store Connect API
```

---

## 📊 构建配置检查清单

### 主应用配置

- [ ] Bundle ID 正确设置
- [ ] Team 已选择
- [ ] Code Sign Identity 为 Distribution
- [ ] Provisioning Profile 已选择
- [ ] Deployment Target 为 16.0+
- [ ] Version 和 Build 已更新
- [ ] 没有编译警告
- [ ] 没有 DEBUG 宏定义

### Widget Extension 配置

- [ ] Bundle ID 为 主应用.widgetname
- [ ] 使用相同的 Team
- [ ] Code Sign Identity 一致
- [ ] Provisioning Profile 已配置
- [ ] Deployment Target 一致
- [ ] App Groups 已配置（com.xiaoha.batterywidget）
- [ ] 代码没有错误

### Info.plist 验证

- [ ] Privacy 描述已添加
- [ ] URL Schemes 正确
- [ ] 所需权限已声明
- [ ] 字体和资源已包含

---

## 🚀 快速命令参考

### 构建 Archive

```bash
xcodebuild archive \
  -scheme "小哈电池Widget" \
  -configuration Release \
  -archivePath "build/app.xcarchive"
```

### 导出 IPA（开发版）

```bash
xcodebuild -exportArchive \
  -archivePath "build/app.xcarchive" \
  -exportOptionsPlist exportOptions.plist \
  -exportPath build/
```

### 安装到设备

```bash
# 需要 iOS-App-Installer 或直接用 Xcode
open -a "Xcode" build/app.ipa
```

### 查看符号

```bash
dwarfdump -H build/app.xcarchive/dSYMs/app.app.dSYM/Contents/Resources/DWARF/app
```

---

## 📱 支持的打包格式

| 格式 | 用途 | 大小 | 兼容性 |
|-----|------|------|--------|
| .xcarchive | Xcode 存档 | 最大 | Xcode only |
| .ipa | App Package | 最小 | iOS 设备 |
| .app | 应用包 | 中等 | macOS + iOS |

---

## ✅ 发布前最终检查

- [ ] 版本号已更新
- [ ] 构建号已增加
- [ ] 所有代码已提交
- [ ] 没有 DEBUG 日志
- [ ] 隐私政策已准备
- [ ] 应用图标已验证
- [ ] 屏幕截图已准备
- [ ] 应用描述已准备
- [ ] 关键词已设置
- [ ] 支持信息已填写

---

## 📞 打包问题诊断

如果遇到打包失败，按以下步骤诊断：

```
1. 清空缓存
   rm -rf ~/Library/Developer/Xcode/DerivedData

2. 更新证书
   从 Apple Developer 重新下载

3. 检查日志
   Product → Scheme → Edit Scheme → Build → Pre-actions
   查看构建输出

4. 验证配置
   检查所有签名和描述符设置

5. 尝试 Clean Build
   Product → Clean Build Folder (Shift+Cmd+K)

6. 重新构建
   Product → Build (Cmd+B)
   然后再 Archive
```

---

## 🎯 下一步

打包完成后：

1. **TestFlight 测试**（推荐）
   - 发给内部测试人员
   - 收集反馈
   - 修复问题

2. **App Store 提交**
   - 准备应用信息
   - 上传屏幕截图
   - 提交审核

3. **发布**
   - 监控用户反馈
   - 准备更新计划
   - 持续优化

---

**打包指南完成！** 👍

需要帮助？查看特定问题的故障排查部分。
