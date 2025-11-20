# GitHub Actions 自动打包配置指南

## 🎯 目标

使用 GitHub Actions 在云端 macOS 环境自动构建和打包 iOS IPA 文件。

---

## ⚡ 快速开始

### 第一步：上传工作流文件

工作流文件已创建在：
```
.github/workflows/build-ios.yml
```

提交到 GitHub：

```bash
git add .github/workflows/build-ios.yml
git commit -m "Add GitHub Actions iOS build workflow"
git push origin main
```

### 第二步：配置签名密钥（可选）

如果你想自动签名，需要在 GitHub 中配置密钥。

**不配置的情况：**
- 使用自动签名（推荐简单项目）
- 需要在 Xcode 中先配置好签名

**配置密钥的情况：**
- 自动导入签名证书
- 自动使用 Provisioning Profile
- 完全无人值守构建

---

## 🔑 配置签名密钥（可选）

### 步骤 1：导出签名证书

**在 Mac 上执行：**

```bash
# 打开 Keychain Access
open /Applications/Utilities/Keychain\ Access.app

# 1. 找到你的开发或发布证书
# 2. 右键 → 导出
# 3. 保存为 certificate.p12
# 4. 设置密码（记住这个密码）
```

### 步骤 2：将证书转为 Base64

```bash
base64 -i certificate.p12 -o certificate.b64

# 或者用 Python
python3 << 'EOF'
import base64
with open('certificate.p12', 'rb') as f:
    encoded = base64.b64encode(f.read()).decode()
print(encoded)
EOF
```

### 步骤 3：导出 Provisioning Profile

```bash
# 通常位置
ls ~/Library/MobileDevice/Provisioning\ Profiles/

# 转为 Base64
base64 -i ~/Library/MobileDevice/Provisioning\ Profiles/YourProfile.mobileprovision
```

### 步骤 4：添加到 GitHub Secrets

1. 打开 GitHub 仓库
2. 进入 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**
4. 添加以下密钥：

| 密钥名 | 值 | 说明 |
|-------|-----|------|
| `BUILD_CERTIFICATE_BASE64` | 证书的 Base64 编码 | iOS 签名证书 |
| `P12_PASSWORD` | 证书密码 | p12 文件的密码 |
| `PROVISIONING_PROFILE_BASE64` | Provisioning Profile 的 Base64 | 配置文件 |
| `KEYCHAIN_PASSWORD` | 任意密码 | 构建时创建的 Keychain 密码 |

---

## 🚀 触发自动构建

### 方式 1：推送代码自动触发

```bash
git add .
git commit -m "Update iOS code"
git push origin main
```

当 `iOS/` 目录中的文件变化时，自动触发构建。

### 方式 2：手动触发

1. 进入 GitHub 仓库
2. 点击 **Actions** 标签
3. 左边选择 **Build iOS IPA**
4. 点击 **Run workflow**
5. 选择 **Branch** 和 **Build type**
6. 点击 **Run workflow**

### 方式 3：通过 Pull Request 触发

创建 PR 时自动构建，验证代码质量。

---

## 📊 工作流说明

### 工作流步骤

```
[1] 检出代码
    └─ 从 GitHub 拉取最新代码

[2] 显示环境信息
    └─ 显示 macOS、Xcode、Swift 版本

[3] 导入签名证书 (可选)
    └─ 如果配置了 secrets，自动导入

[4] 安装 Provisioning Profile (可选)
    └─ 如果配置了 secrets，自动安装

[5] 构建 Archive
    └─ 运行 xcodebuild archive（3-10 分钟）

[6] 验证 Archive
    └─ 检查构建是否成功

[7] 生成导出配置
    └─ 根据构建类型生成 exportOptions.plist

[8] 导出 IPA
    └─ 生成最终的 .ipa 文件

[9] 检查 IPA 文件
    └─ 验证 IPA 完整性

[10] 上传 IPA 制品
     └─ 保存到 GitHub Artifacts

[11] 上传构建日志
     └─ 便于问题诊断

[12] 成功/失败通知
     └─ 显示构建结果
```

---

## 📥 下载 IPA 文件

### 从 GitHub Actions 下载

1. 进入仓库的 **Actions** 标签
2. 找到对应的构建记录（绿色对勾表示成功）
3. 点击构建记录
4. 向下滚动找到 **Artifacts** 部分
5. 下载 `ios-ipa-{run-number}` 文件

### 获得的文件

```
ios-ipa-123/
├── 小哈电池Widget.ipa  ← 这是你需要的文件
└── (其他生成的文件)
```

---

## 🔧 高级配置

### 自定义构建参数

编辑 `.github/workflows/build-ios.yml`：

```yaml
# 修改 Scheme 名称
-scheme "小哈电池Widget"

# 修改配置
-configuration Release

# 修改输出路径
-archivePath build/app.xcarchive
```

### 支持多个分支

```yaml
on:
  push:
    branches: [ main, develop, staging ]
```

### 定时自动构建

```yaml
schedule:
  - cron: '0 2 * * *'  # 每天凌晨 2 点构建
```

### 构建条件

仅在特定条件下构建：

```yaml
if: |
  github.event_name == 'push' || 
  github.event_name == 'workflow_dispatch'
```

---

## 🐛 故障排查

### 问题 1：Archive 构建失败

```
error: Unable to find a matching provisioning profile
```

**解决方案：**
- 在 Xcode 中先手动签名一次
- 或配置 Provisioning Profile 的 Base64
- 检查 Bundle ID 是否正确

### 问题 2：IPA 导出失败

```
error: Failed to export archive
```

**解决方案：**
- 查看 export.log 文件（下载制品）
- 检查 exportOptions.plist 配置
- 验证签名证书有效期

### 问题 3：没有找到 IPA 文件

```
❌ 未找到 IPA 文件
```

**解决方案：**
- 查看完整的构建日志
- 检查 build.log 和 export.log
- 确认 Archive 步骤成功

### 问题 4：Keychain 相关错误

```
security: The specified item could not be found in the keychain
```

**解决方案：**
- 检查 P12_PASSWORD 是否正确
- 确认 certificate.p12 有效
- 尝试不配置 secrets，使用自动签名

---

## 📝 查看构建日志

### 在线查看

1. 打开构建记录
2. 展开各个步骤查看详细日志
3. 看红色错误或黄色警告

### 下载日志文件

1. 下载 `build-logs-{run-number}` 制品
2. 查看 `build.log` 和 `export.log`

---

## 🔐 安全建议

### 保护敏感信息

- ✅ **不要**将证书提交到 Git
- ✅ **不要**在日志中输出 secrets
- ✅ 定期轮换密码
- ✅ 限制 Actions 的权限

### 限制访问

```yaml
permissions:
  contents: read
  actions: read
```

---

## 💡 最佳实践

### 1. 分离环境

```yaml
# 不同分支不同配置
if: github.ref == 'refs/heads/main'
  BUILD_TYPE: 'app-store'
else
  BUILD_TYPE: 'ad-hoc'
```

### 2. 定期清理

工作流已配置自动清理临时文件。

### 3. 通知集成

可以集成钉钉、Slack、邮件等通知：

```yaml
- name: 发送钉钉通知
  uses: xxxxx/action-dingding@v1
  with:
    webhook: ${{ secrets.DINGDING_WEBHOOK }}
    message: "iOS IPA 构建完成"
```

### 4. 自动上传 TestFlight

```yaml
- name: 上传到 TestFlight
  run: |
    xcrun altool --upload-app \
      --file build/Payload/*.ipa \
      --username ${{ secrets.APPLE_ID }} \
      --password ${{ secrets.APPLE_PASSWORD }}
```

---

## 📊 成本估算

### GitHub Actions 免费额度

- **Public 仓库**：无限免费
- **Private 仓库**：每月 2,000 分钟

### macOS 构建时间

- 每次构建：5-10 分钟
- 月构建数：最多 10-15 次（免费额度内）

---

## ✅ 检查清单

- [ ] 工作流文件已上传到 `.github/workflows/build-ios.yml`
- [ ] 已推送到 GitHub
- [ ] 代码在 `iOS/` 目录中
- [ ] Xcode 项目配置正确
- [ ] 可选：已配置签名 secrets
- [ ] 已测试手动触发构建
- [ ] 成功下载生成的 IPA 文件

---

## 🎯 下一步

### 1. 测试构建

```bash
git push origin main
# 进入 GitHub Actions 观察构建过程
```

### 2. 下载 IPA

完成后从 Artifacts 下载 IPA 文件。

### 3. 测试分发

- 用 TestFlight 分发给测试人员
- 或直接提交到 App Store

### 4. 优化工作流

根据需要调整构建参数和分发方式。

---

## 📞 常见问题

**Q: 能在 Windows 上触发构建吗？**  
A: 可以！通过 GitHub 网页或 `git push` 即可触发。构建在云端 macOS 上执行。

**Q: 多久能完成一次构建？**  
A: 通常 5-15 分钟，取决于代码大小和网络。

**Q: IPA 文件能保存多久？**  
A: 默认 30 天，可通过 `retention-days` 修改。

**Q: 可以自动上传到 App Store 吗？**  
A: 可以！需要添加 App Store Connect API 密钥。

---

**现在你有了一个完整的自动构建系统！** 🚀
