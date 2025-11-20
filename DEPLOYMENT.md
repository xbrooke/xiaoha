## 本地运行

```bash
cd server
npm install
npm run dev
```

访问 http://localhost:3000

## 部署到 Netlify

### 方式 1: 从 GitHub 部署（推荐）

1. **初始化 Git 仓库**
```bash
cd xiaoha-battery-widget-0.1.0
git init
git add .
git commit -m "Initial commit"
```

2. **推送到 GitHub**
   - 在 GitHub 创建新仓库
   - 按照指引推送代码

3. **连接 Netlify**
   - 登录 [Netlify](https://app.netlify.com)
   - 点击 "New site from Git"
   - 选择 GitHub 仓库
   - 构建设置：
     - Build command: `npm install`
     - Publish directory: `server/public`
     - Functions directory: `server/functions`

4. **设置环境变量**
   - Site settings → Environment variables
   - 添加 `NODE_ENV=production`

### 方式 2: 直接拖拽部署

1. **构建项目**
```bash
cd server
npm install
```

2. **压缩 `server` 文件夹为 ZIP**

3. **在 Netlify 拖拽上传 ZIP 文件**

## 更新 Android 客户端

修改 `BatteryWidgetConfigureActivity.kt` 中的基础 URL：

```kotlin
// 原值
val baseUrl = prefs.getString("baseUrl", "https://xiaoha.linkof.link/")

// 改为你的 Netlify 域名，例如：
val baseUrl = prefs.getString("baseUrl", "https://your-site-name.netlify.app/")
```

## 更新 iOS 脚本

修改 `widget.js`：

```javascript
// 原值
const decode_endpoint = `https://xiaoha.linkof.link/decode`;
const preparams_endpoint = `https://xiaoha.linkof.link/preparams?batteryNo=${batteryNo}`;

// 改为
const decode_endpoint = `https://your-site-name.netlify.app/decode`;
const preparams_endpoint = `https://your-site-name.netlify.app/preparams?batteryNo=${batteryNo}`;
```

## API 接口说明

### 1. 获取预处理参数

```
POST /preparams?batteryNo={电池编号}
Content-Type: text/plain

{token}

响应：
{
  "data": {
    "url": "官方API地址",
    "body": "加密请求体",
    "headers": {"key": "value"}
  }
}
```

### 2. 解码电池数据

```
POST /decode
Content-Type: application/octet-stream

{二进制加密数据}

响应：
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

### 3. 健康检查

```
GET /health

响应：
{
  "status": "healthy"
}
```

## 常见问题

**Q: 部署后提示 404？**
A: 检查 Netlify 构建日志，确保 functions 文件夹被正确识别。

**Q: CORS 错误？**
A: 响应头已包含 `Access-Control-Allow-Origin: *`，检查客户端请求格式。

**Q: 解码返回错误？**
A: 检查二进制数据格式，确保正确传递 Content-Type。

## 注意事项

- 服务器地址需要在 Android 和 iOS 两端同时更新
- 确保 baseUrl 末尾有 `/`
- Token 数据在本地处理，服务器仅作转发
- Netlify Functions 有请求超时限制（10 秒），已在代码中配置

## 本地测试 Netlify Functions

```bash
npm install -g netlify-cli
netlify dev
```

访问 http://localhost:8888，Functions 将模拟在 /.netlify/functions/ 路径下
