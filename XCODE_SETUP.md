# Xcode 项目配置完整指南

## 📋 快速概览

本指南将帮助你在 Xcode 中完整配置小哈电池Widget iOS版本。

## 🎯 系统要求

- **macOS**: 12.0 或更新版本
- **Xcode**: 14.0 或更新版本（推荐 15.0+）
- **iOS Target**: 16.0 或更新版本
- **Swift**: 5.7 或更新版本

## ⚡ 第一步：创建新 Xcode 项目

### 1.1 创建应用项目

```
1. 打开 Xcode
2. 菜单：File → New → Project
3. 选择 "iOS"
4. 选择 "App"
5. 点击 "Next"
```

### 1.2 填写项目信息

| 字段 | 值 |
|-----|-----|
| Product Name | 小哈电池Widget |
| Team | 你的 Apple Developer Team |
| Organization Identifier | com.yourcompany |
| Bundle Identifier | com.yourcompany.batterywidget |
| Interface | SwiftUI |
| Lifecycle | SwiftApp |
| Language | Swift |
| Use Core Data | ❌ |
| Include Tests | ❌ |

### 1.3 选择保存位置

在 "Save As" 对话框中：
- 输入项目名称：`BatteryWidgetApp`
- 选择保存位置
- 点击 "Create"

## 🔧 第二步：添加 Widget Extension

### 2.1 创建 Widget Target

```
1. 在 Xcode 中打开项目
2. 菜单：File → New → Target
3. 搜索：Widget
4. 选择：Widget Extension
5. 点击 "Next"
```

### 2.2 配置 Widget Extension

| 字段 | 值 |
|-----|-----|
| Product Name | BatteryWidgetExtension |
| Team | 同上 |
| Organization Identifier | com.yourcompany |
| Bundle Identifier | com.yourcompany.batterywidget.widget |
| Language | Swift |

### 2.3 配置 Supported Families

在创建对话框中：

```
支持的小部件尺寸：
☑ systemSmall      (小屏/锁屏)
☑ systemMedium    (中等屏幕)
☑ systemLarge     (大屏幕)
☑ systemExtraLarge (超大屏幕, iOS 17+)
☑ accessoryRectangular (锁屏矩形)
☑ accessoryCircular (锁屏圆形)
```

### 2.4 完成创建

点击 "Finish" 创建 Widget Extension。

## 🔐 第三步：配置 App Groups

App Groups 让主应用和 Widget Extension 能共享数据。

### 3.1 主应用配置

```
1. 在 Xcode 左侧选择 Project
2. 选择 Targets → [主应用名]
3. 点击 "Signing & Capabilities"
4. 点击 "+ Capability"
5. 搜索：App Groups
6. 双击 "App Groups" 添加
```

### 3.2 设置 Container ID

```
1. 在刚添加的 App Groups 中
2. 在 "Container ID" 输入框中输入：
   group.com.xiaoha.batterywidget
```

### 3.3 Widget Extension 配置

对 BatteryWidgetExtension Target 重复 3.1-3.2 步骤。

## 📄 第四步：配置 Info.plist

### 4.1 主应用 Info.plist

在 Xcode 中打开 `Info.plist`，添加以下键值对：

**方法1：使用 Xcode 图形界面**

```
1. 选择 Info.plist
2. 找到空白行
3. 点击 "+" 按钮
4. 添加以下内容：

☐ Privacy - Local Network Usage Description
  值：需要访问本地网络以获取电池数据

☐ Privacy - Bonjour Services
  值：（数组）
    - http._tcp

☐ NSAllowsLocalNetworking
  值：YES
```

**方法2：直接编辑 XML**

右键点击 Info.plist → "Open As" → "Source Code"，添加：

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>需要访问本地网络以获取电池数据</string>
<key>NSBonjourServices</key>
<array>
    <string>_http._tcp</string>
</array>
<key>NSAllowsLocalNetworking</key>
<true/>
```

## 📁 第五步：添加源代码文件

### 5.1 主应用代码文件

在 Xcode 中，右键点击项目文件夹：

```
1. 右键 → "Add Files to [Project Name]"
2. 选择以下文件：
   ✓ BatteryWidget.swift
   ✓ BatteryWidgetViewModel.swift
   ✓ BatteryNetworkService.swift
3. 勾选：
   ☑ Copy items if needed
   ☑ Create groups
   ☑ Add to targets: [主应用名]
4. 点击 "Add"
```

### 5.2 Widget Extension 代码文件

对 Widget Extension：

```
1. 右键项目 → "Add Files to [Project Name]"
2. 选择：
   ✓ BatteryWidgetSmall.swift
3. 勾选：
   ☑ Copy items if needed
   ☑ Create groups
   ☑ Add to targets: BatteryWidgetExtension
4. 点击 "Add"
```

同时将 BatteryNetworkService.swift 和 BatteryWidgetViewModel.swift 也添加到 Widget Extension：

```
选择这些文件 → 右键 → File Inspector → Targets
☑ 勾选 BatteryWidgetExtension
```

## 🔨 第六步：编译设置

### 6.1 最低部署目标设置

```
1. 选择 Project
2. 选择 Build Settings
3. 搜索：Minimum Deployments
4. 设置为：iOS 16.0
```

### 6.2 Swift 语言版本

```
搜索：Swift Language
确保设置为：5.7 或更新版本
```

### 6.3 代码签名

```
搜索：Code Sign Identity
确保设置为：Apple Development
```

## ✅ 第七步：验证项目配置

### 7.1 检查文件配置

在 File Inspector 中验证每个文件：
- 正确的 Target 被选中
- 文件在正确的文件夹中

### 7.2 检查 Build Phases

```
选择 Target → Build Phases
验证所有 Swift 文件都在 "Compile Sources" 中
```

### 7.3 清理构建缓存

```
菜单：Product → Clean Build Folder
快捷键：Shift + Cmd + K
```

## 🏃 第八步：构建和运行

### 8.1 选择目标

```
在 Xcode 顶部工具栏：
选择 Target: 小哈电池Widget (或你的应用名)
选择 Destination: iPhone 15 Pro (或其他模拟器)
```

### 8.2 构建应用

```
菜单：Product → Build
快捷键：Cmd + B
```

### 8.3 运行应用

```
菜单：Product → Run
快捷键：Cmd + R
```

### 8.4 测试 Widget Extension

```
1. 使用 Cmd + R 运行主应用
2. 在模拟器中长按主屏幕
3. 点击 "编辑"
4. 点击 "+" 按钮
5. 搜索并选择你的应用
6. 添加小部件
```

## 🐛 常见问题排查

### 编译错误：Module not found

```
症状：error: no such module 'xxx'
原因：文件未正确添加到 Target
解决：
1. 选择文件 → File Inspector
2. Targets 中勾选正确的 Target
3. Product → Clean Build Folder
4. 重新编译
```

### 运行时错误：Symbol not found

```
症状：dyld: Symbol not found
原因：Widget Extension 没有包含必要的代码文件
解决：
1. 确保所有必要文件都添加到了 Widget Extension
2. 特别是 BatteryNetworkService.swift
3. 重新编译
```

### App Groups 不工作

```
症状：数据无法在应用和小组件间共享
原因：
1. App Groups 未正确配置
2. Bundle ID 不匹配
解决：
1. 验证两个 Target 的 Container ID 相同
2. 删除构建文件：rm -rf ~/Library/Developer/Xcode/DerivedData/*
3. 重新编译
```

### 小组件显示错误

```
症状：Widget 显示红色错误或不显示
原因：
1. Widget Code 有语法错误
2. 数据格式不正确
解决：
1. 检查 Xcode 编译器错误
2. 使用 Widget Preview 调试
3. 查看 Console 输出
```

## 📱 在模拟器中测试 Widget

### 方法 1：Widget 预览

```
1. 打开 BatteryWidgetSmall.swift
2. 点击右上角 "Canvas" 或按 Cmd + Opt + Return
3. 在预览中可以实时看到 Widget 效果
```

### 方法 2：添加到模拟器主屏

```
1. 运行应用
2. 在模拟器中长按主屏幕空白处
3. 点击左下角 "+"
4. 搜索应用名称
5. 选择 Widget 添加
```

### 方法 3：模拟器中的锁屏 Widget (iOS 16+)

```
1. 在模拟器中长按锁屏
2. 点击 "+" 或 "Customize"
3. 搜索应用名称
4. 添加 Widget
```

## 📦 打包发布

### 准备发布

```
1. 更新版本号：
   Product → Scheme → Edit Scheme
   或 Project → General → Version/Build

2. 收集必要信息：
   - App Name
   - Description
   - Screenshots
   - Keywords

3. 生成 Archive：
   Product → Archive
   选择最新的 Archive
   点击 "Distribute App"
```

## 🔍 检查清单

编译前检查以下项目：

- [ ] Xcode 14.0+ 已安装
- [ ] 项目创建完成
- [ ] Widget Extension 已添加
- [ ] App Groups 已配置
- [ ] 所有源代码文件已添加
- [ ] 最低部署目标设置为 iOS 16.0+
- [ ] Info.plist 已配置
- [ ] Build Settings 验证无误
- [ ] 没有编译警告和错误
- [ ] Widget Preview 可以正常显示

## 🚀 下一步

配置完成后：

1. 运行应用测试基本功能
2. 配置电池编号和 Token
3. 测试 API 连接
4. 将小部件添加到主屏和锁屏
5. 验证数据自动刷新

---

**更新日期**: 2024年
**Xcode 版本**: 15.0+
**iOS 目标版本**: 16.0+
