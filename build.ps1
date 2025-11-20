param(
    [string]$Method = "app-store",
    [string]$OutputDir = "."
)

# iOS 一键打包脚本 (PowerShell Windows 版本)
# 用法: powershell -ExecutionPolicy Bypass -File build.ps1 -Method app-store -OutputDir .

$ErrorActionPreference = "Stop"

# 配置
$Scheme = "小哈电池Widget"
$Configuration = "Release"
$ProjectPath = "."
$DerivedDataPath = "build\DerivedData"
$ArchivePath = "build\archive.xcarchive"
$ExportMethod = $Method
$Output = $OutputDir

# 颜色输出辅助函数
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

Write-Info "========================================"
Write-Info "  iOS 一键打包脚本 (Windows PowerShell)"
Write-Info "========================================"
Write-Host ""

# 检查是否在 Mac 上（因为 xcodebuild 需要 macOS）
if ($PSVersionTable.Platform -eq "Win32NT") {
    Write-Error "❌ 错误：此脚本只能在 macOS 上运行"
    Write-Host ""
    Write-Host "iOS 打包需要以下条件："
    Write-Host "  1. Mac 电脑（运行 macOS 12+）"
    Write-Host "  2. Xcode 14+ 已安装"
    Write-Host "  3. Apple Developer 账号"
    Write-Host ""
    Write-Host "推荐做法："
    Write-Host "  • 在 Mac 上运行 build.sh 脚本"
    Write-Host "  • 或使用 Xcode GUI 进行打包"
    Write-Host "  • 或通过 SSH 连接到 Mac 执行远程打包"
    exit 1
}

# 验证项目存在
$xcodeproj = Get-ChildItem -Filter "*.xcodeproj" -ErrorAction SilentlyContinue
if (-not $xcodeproj) {
    Write-Warning "⚠️  警告：未在 Xcode 项目目录中"
    exit 1
}

# 显示配置信息
Write-Success "📋 打包配置"
Write-Host "  Scheme: $Scheme"
Write-Host "  Configuration: $Configuration"
Write-Host "  Method: $ExportMethod"
Write-Host "  Output: $Output"
Write-Host ""

# 步骤 1: 清理构建目录
Write-Info "[1/5] 清理旧构建文件..."
if (Test-Path "build") {
    Remove-Item -Path "build" -Recurse -Force
}
New-Item -ItemType Directory -Path "build" -Force | Out-Null

# 步骤 2: 构建 Archive
Write-Info "[2/5] 构建 Archive..."
Write-Host "      这可能需要 2-5 分钟..."

$archiveCmd = @(
    "xcodebuild", "archive",
    "-scheme", $Scheme,
    "-configuration", $Configuration,
    "-derivedDataPath", $DerivedDataPath,
    "-archivePath", $ArchivePath,
    "-allowProvisioningUpdates",
    "CODE_SIGN_STYLE=Automatic"
)

& $archiveCmd 2>&1 | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Archive 构建失败"
    exit 1
}

Write-Success "✓ Archive 构建成功"
Write-Host ""

# 步骤 3: 检查 Archive
Write-Info "[3/5] 检查 Archive 文件..."
if (Test-Path $ArchivePath) {
    $archiveSize = (Get-Item $ArchivePath | Measure-Object -Property Length -Sum).Sum
    $archiveSizeMB = [math]::Round($archiveSize / 1MB, 2)
    Write-Host "      大小: $($archiveSizeMB) MB"
    Write-Success "✓ Archive 文件有效"
} else {
    Write-Error "❌ Archive 文件不存在"
    exit 1
}
Write-Host ""

# 步骤 4: 生成 exportOptions.plist
Write-Info "[4/5] 生成导出配置..."

$exportPlistPath = "build\exportOptions.plist"

switch ($ExportMethod) {
    "app-store" {
        $plistContent = @'
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
'@
    }
    "ad-hoc" {
        $plistContent = @'
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
'@
    }
    "enterprise" {
        $plistContent = @'
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
'@
    }
    default {
        $plistContent = @'
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
'@
    }
}

$plistContent | Out-File -FilePath $exportPlistPath -Encoding UTF8

# 步骤 5: 导出 IPA
Write-Info "[5/5] 导出 IPA 文件..."
Write-Host "      方法: $ExportMethod"

$exportCmd = @(
    "xcodebuild", "-exportArchive",
    "-archivePath", $ArchivePath,
    "-exportPath", "build\Payload",
    "-exportOptionsPlist", $exportPlistPath,
    "-allowProvisioningUpdates"
)

& $exportCmd 2>&1 | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ IPA 导出失败"
    Write-Error "可能原因:"
    Write-Error "  - 签名证书未配置"
    Write-Error "  - Provisioning Profile 不匹配"
    Write-Error "  - Team ID 未设置"
    exit 1
}

# 查找 IPA 文件
$ipaFile = Get-ChildItem -Path "build\Payload" -Filter "*.ipa" -Recurse | Select-Object -First 1

if (-not $ipaFile) {
    Write-Error "❌ 未找到 IPA 文件"
    exit 1
}

# 复制到输出目录
$finalIpa = Join-Path $Output $ipaFile.Name
Copy-Item -Path $ipaFile.FullName -Destination $finalIpa -Force

Write-Success "✓ IPA 导出成功"
Write-Host ""

# 显示结果
Write-Success "========================================"
Write-Success "  ✅ 打包成功！"
Write-Success "========================================"
Write-Host ""

Write-Host "📦 IPA 文件位置:"
Write-Host "   $finalIpa"
Write-Host ""

Write-Host "📊 文件信息:"
$ipaSize = [math]::Round((Get-Item $finalIpa).Length / 1MB, 2)
Write-Host "   大小: $($ipaSize) MB"
Write-Host ""

Write-Host "下一步:"
Write-Host "   • TestFlight: 上传到 App Store Connect"
Write-Host "   • 手机安装: 通过 Xcode 连接设备后安装"
Write-Host "   • 分发: 发送 .ipa 文件给其他人"
Write-Host ""
