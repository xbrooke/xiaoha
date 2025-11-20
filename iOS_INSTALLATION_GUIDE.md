# iOS 版本安装与使用指南

## 📱 项目概述

这是小哈共享充电宝电池监控小组件的完整 **iOS 原生应用版本**，支持：
- 主屏幕小组件（小、中、大尺寸）
- iOS 16+ 锁屏小组件
- 精美的SwiftUI界面
- 完整的API测试功能

## 🛠️ 安装步骤

### 前置要求
- **Xcode 14.0+** (推荐 15.0+)
- **macOS 12.0+**
- **iOS 16.0+** 目标设备

### 第一步：准备项目文件

将以下文件复制到 Xcode 项目：

```
YourApp/
├── BatteryWidget.swift          # 主应用UI界面
├── BatteryWidgetViewModel.swift # 业务逻辑ViewModel
├── BatteryNetworkService.swift  # 网络请求服务
└── BatteryWidgetSmall.swift     # 小组件实现
```

### 第二步：Xcode 项目配置

#### 2.1 创建新项目
```
File → New → Project
选择 iOS → App
填写信息：
- Product Name: 小哈电池Widget (或自定义)
- Organization Identifier: com.yourcompany.batterywidget
- Interface: SwiftUI
- Lifecycle: SwiftApp
- Language: Swift
```

#### 2.2 添加Widget Extension
```
File → New → Target
搜索 "Widget Extension"
选择 iOS Widget Extension
填写信息：
- Product Name: BatteryWidgetExtension
- Supported Families: 
  ✓ Small
  ✓ Medium  
  ✓ Large
  ✓ Lock Screen (iOS 16+)
```

#### 2.3 配置 App Groups
在 Xcode 中为两个 target 配置：

**主应用 Target：**
1. 选择 Project → Targets → [主应用名]
2. Signing & Capabilities
3. "+ Capability"
4. 搜索 "App Groups" 并添加
5. 输入 Container ID: `group.com.xiaoha.batterywidget`

**Widget Extension Target：**
1. 选择 Project → Targets → BatteryWidgetExtension
2. 重复上述步骤

#### 2.4 更新 Info.plist

主应用 Info.plist 添加：
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>需要访问本地网络以获取电池数据</string>
<key>NSBonjourServices</key>
<array>
    <string>_http._tcp</string>
</array>
```

### 第三步：代码集成

#### 3.1 替换 App 入口 (BatteryWidget.swift)

将提供的 `BatteryWidget.swift` 的内容复制到项目的 `App.swift` 或主entry文件。

#### 3.2 添加 ViewModel (BatteryWidgetViewModel.swift)

复制整个文件到项目。

#### 3.3 添加网络服务 (BatteryNetworkService.swift)

复制整个文件到项目。

#### 3.4 配置 Widget Extension

将 `BatteryWidgetSmall.swift` 的内容复制到 Widget Extension 的 `[ProductName]Widget.swift` 文件。

### 第四步：构建和运行

#### 4.1 构建主应用
```
1. 选择 target: 小哈电池Widget
2. 选择模拟器或真机
3. Cmd + B 构建
4. Cmd + R 运行
```

#### 4.2 构建 Widget
```
1. 选择 target: BatteryWidgetExtension
2. Cmd + B 构建
```

## 🚀 使用方式

### 第一次使用

1. **启动应用**
   - 打开 iOS 应用
   - 看到"未配置"提示

2. **配置信息**
   - 点击"立即配置"
   - 输入电池编号（从小哈小程序获取）
   - 输入 Token（通过抓包获取，Base64编码）

3. **测试连接**
   - 点击"测试连接"按钮
   - 查看详细的 API 日志
   - 确认接口可用

4. **保存配置**
   - 点击"保存配置"
   - 应用自动获取电池数据

### 添加小组件到主屏

1. 在主屏幕长按 → "编辑主屏幕"
2. 点击左上角 "+" 按钮
3. 搜索应用名称
4. 选择小部件：
   - **Small Widget** - 小尺寸锁屏/主屏
   - **Large Widget** - 大尺寸主屏
5. 点击"添加小部件"

### 添加小组件到锁屏 (iOS 16+)

1. 长按锁屏
2. 点击 "+" 按钮
3. 搜索应用名称
4. 选择小部件
5. 选择合适的大小和样式
6. 点击完成

### 自动刷新

小组件会自动每5分钟刷新一次电池数据。

## 📋 获取 Token 的详细步骤

### iOS 用户

#### 使用 Charles Proxy（推荐）
1. 从 App Store 下载 Charles Proxy
2. 在 Charles 中配置 HTTPS 代理证书
3. 在 iPhone 设置 → Wi-Fi → 配置代理
4. 打开小哈租电小程序
5. 查看电池详情页面
6. 在 Charles 中找到对应的 POST 请求
7. 复制 Request Body（应该是 Base64 编码的长字符串）

#### 使用 Surge
1. 下载 Surge（付费）
2. 启用 MitM 代理
3. 打开小哈小程序查看电池
4. 在 Surge 中查看请求
5. 复制完整的 Body

#### 使用 Thor
1. 下载 Thor（免费）
2. 配置 SSL 证书
3. 打开小哈小程序
4. 在 Thor 中拦截电池查询请求
5. 复制 Body

### Token 格式检查
- 应该是很长的 Base64 编码字符串
- 长度通常 > 500 字符
- 包含加密的用户认证信息

## 🔍 API 流程详解

### 三步 API 调用机制

#### 步骤 1: 获取预处理参数
```
POST https://xiaoha.linkof.link/preparams?batteryNo=8903115649
Header: Content-Type: text/plain
Body: [你的Token]

返回:
{
  "data": {
    "url": "https://...",
    "body": "{encrypted_json}",
    "headers": {
      "Authorization": "...",
      ...
    }
  }
}
```

#### 步骤 2: 获取加密电池数据
```
POST {从步骤1获取的URL}
Headers: {从步骤1获取的headers}
Body: {从步骤1获取的body}

返回: 二进制加密数据
```

#### 步骤 3: 解码电池数据
```
POST https://xiaoha.linkof.link/decode
Header: Content-Type: application/octet-stream
Body: {二进制加密数据}

返回:
{
  "data": {
    "data": {
      "bindBatteries": [
        {
          "batteryLife": 85,
          "reportTime": "2024-01-01T12:00:00"
        }
      ]
    }
  }
}
```

## 🧪 功能测试

### 测试清单

- [ ] **主应用启动** - 应用正常打开
- [ ] **配置保存** - Token 和电池编号保存成功
- [ ] **电池数据显示** - 电量百分比正确显示
- [ ] **API 测试** - "测试连接"功能正常
- [ ] **小组件显示** - 小组件能正常显示在主屏
- [ ] **锁屏小组件** - iOS 16+ 锁屏小组件正常显示
- [ ] **自动刷新** - 小组件定期自动更新
- [ ] **错误处理** - 网络错误时显示友好提示

### 常见问题排查

#### 问题：小组件显示"未配置"
**解决：**
1. 确保主应用已保存配置
2. 检查 App Groups 是否正确配置
3. 重启应用和小组件

#### 问题：API 测试失败
**解决：**
1. 检查 Token 是否正确复制
2. 检查电池编号是否正确
3. 检查网络连接
4. 查看详细错误日志

#### 问题：小组件不更新
**解决：**
1. 长按小组件 → 编辑小组件
2. 确保网络连接正常
3. 强制刷新：长按 → 删除 → 重新添加

#### 问题：Xcode 编译错误
**解决：**
1. Product → Clean Build Folder (Cmd + Shift + K)
2. 删除 ~/Library/Developer/Xcode/DerivedData/
3. 重新构建

## 📚 代码结构说明

### BatteryWidget.swift (405 行)
- `ContentView` - 主界面，显示电池状态
- `BatteryStatusCard` - 电池状态卡片，环形进度显示
- `ConfigurationView` - 配置界面，输入 Token 和电池编号

### BatteryWidgetViewModel.swift (208 行)
- `BatteryWidgetViewModel` - 业务逻辑和状态管理
  - `fetchBatteryData()` - 获取电池数据
  - `testConnection()` - 测试 API 连接
  - `saveConfiguration()` - 保存配置
  - `loadConfiguration()` - 加载配置

### BatteryNetworkService.swift (211 行)
- `BatteryNetworkService` - 网络请求服务
  - `fetchBatteryData()` - 完整的三步 API 调用
  - `testConnection()` - 生成测试日志
  - `getPreparams()` - 步骤1
  - `getBatteryData()` - 步骤2
  - `decodeBatteryData()` - 步骤3

### BatteryWidgetSmall.swift (428 行)
- `SmallBatteryWidget` - 小屏小组件定义
- `LargeBatteryWidget` - 大屏小组件定义
- `SmallBatteryWidgetEntryView` - 小组件UI
- `LargeBatteryWidgetEntryView` - 大小组件UI
- Widget Provider - 数据提供和刷新逻辑

## 🔐 安全说明

- **Token 安全**：Token 只在本地设备存储，不上传服务器
- **数据加密**：所有 API 通信使用 HTTPS
- **本地处理**：解密数据仅在本地进行，不上传
- **Keychain**：可选使用 Keychain 替代 UserDefaults 进一步加强安全

## 📦 发布到 App Store

1. 创建 Apple Developer 账号
2. 在 App Store Connect 创建应用
3. 配置证书和描述符
4. 更新 Bundle ID 和版本号
5. 构建 Archive 提交
6. 等待审核

## 🤝 贡献和反馈

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License - 详见 LICENSE 文件

---

**最后更新**: 2024年
**iOS 版本**: 1.0.0
**最低系统**: iOS 16.0
