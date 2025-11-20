//
//  BatteryWidget.swift
//  小哈电池Widget
//
//  iOS 主应用入口
//

import SwiftUI
import WidgetKit

@main
struct BatteryWidgetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(nil) // 支持系统深色模式
        }
    }
}

// MARK: - 主要内容视图
struct ContentView: View {
    @StateObject private var viewModel = BatteryWidgetViewModel()
    @State private var showConfigSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0, green: 0.53, blue: 1),
                        Color(red: 0.3, green: 0.6, blue: 1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // 顶部标题
                    VStack(alignment: .leading, spacing: 8) {
                        Text("小哈电池监控")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("实时电池电量显示")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // 主要内容区域
                    if viewModel.isConfigured {
                        VStack(spacing: 20) {
                            // 电池状态卡片
                            BatteryStatusCard(viewModel: viewModel)
                            
                            // 刷新按钮
                            Button(action: { viewModel.fetchBatteryData() }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("刷新电池状态")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                            }
                            .disabled(viewModel.isLoading)
                            
                            // 配置按钮
                            Button(action: { showConfigSheet = true }) {
                                HStack {
                                    Image(systemName: "gear")
                                    Text("编辑配置")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                    } else {
                        // 未配置状态
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.white)
                            
                            Text("未配置")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("请先配置电池编号和Token")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                            
                            Button(action: { showConfigSheet = true }) {
                                Text("立即配置")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(red: 0, green: 0.53, blue: 1))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                            .padding()
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                    }
                    
                    Spacer()
                    
                    // 底部信息
                    VStack(spacing: 8) {
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 14))
                            Text("版本 1.0.0")
                                .font(.system(size: 12, weight: .regular))
                        }
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("小哈电池Widget")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showConfigSheet) {
            ConfigurationView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadConfiguration()
            if viewModel.isConfigured {
                viewModel.fetchBatteryData()
            }
        }
    }
}

// MARK: - 电池状态卡片
struct BatteryStatusCard: View {
    @ObservedObject var viewModel: BatteryWidgetViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // 进度圆环
            ZStack {
                // 背景圆圈
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 8)
                
                // 进度圆圈
                Circle()
                    .trim(from: 0, to: CGFloat(viewModel.batteryPercentage) / 100)
                    .stroke(Color.white, lineWidth: 8)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: viewModel.batteryPercentage)
                
                // 中央百分比文本
                VStack(spacing: 4) {
                    Text("\(viewModel.batteryPercentage)%")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("电量")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(height: 200)
            .padding()
            
            // 电池信息
            VStack(spacing: 12) {
                HStack {
                    Text("电池编号")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text(viewModel.batteryNo)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("更新时间")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text(viewModel.lastUpdateTime)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                if viewModel.isLoading {
                    HStack {
                        ProgressView()
                            .tint(.white)
                        Text("加载中...")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - 配置视图
struct ConfigurationView: View {
    @ObservedObject var viewModel: BatteryWidgetViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var batteryNo: String = ""
    @State private var token: String = ""
    @State private var showTestResults = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 配置部分
                        VStack(spacing: 16) {
                            Text("基本配置")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // 电池编号输入
                            VStack(alignment: .leading, spacing: 8) {
                                Label("电池编号", systemImage: "number")
                                    .font(.system(size: 14, weight: .semibold))
                                
                                TextField("输入电池编号", text: $batteryNo)
                                    .textFieldStyle(.roundedBorder)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                            }
                            
                            // Token输入
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Token (Base64编码)", systemImage: "key.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                
                                TextField("粘贴抓包获取的Token", text: $token)
                                    .textFieldStyle(.roundedBorder)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .lineLimit(3...5)
                            }
                            
                            Text("💡 通过抓包工具获取Token：在小哈租电小程序查看电池详情时，拷贝请求Body")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // 操作按钮
                        VStack(spacing: 12) {
                            // 测试按钮
                            Button(action: { viewModel.testConnection(batteryNo: batteryNo, token: token) }) {
                                HStack {
                                    Image(systemName: "bolt.fill")
                                    Text("测试连接")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(12)
                            }
                            .disabled(batteryNo.isEmpty || token.isEmpty || viewModel.isLoading)
                            
                            // 保存按钮
                            Button(action: {
                                viewModel.saveConfiguration(batteryNo: batteryNo, token: token)
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("保存配置")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                            .disabled(batteryNo.isEmpty || token.isEmpty)
                        }
                        .padding()
                        
                        // 测试结果
                        if let testLog = viewModel.testLog, !testLog.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("测试结果")
                                        .font(.system(size: 14, weight: .semibold))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        UIPasteboard.general.string = testLog
                                    }) {
                                        Image(systemName: "doc.on.doc")
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                ScrollView {
                                    Text(testLog)
                                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                                        .foregroundColor(.gray)
                                        .textSelection(.enabled)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(height: 200)
                                .padding()
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(8)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("配置设置")
                        .font(.system(size: 16, weight: .semibold))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                batteryNo = viewModel.batteryNo
                token = viewModel.token
            }
        }
    }
}

#Preview {
    ContentView()
}
