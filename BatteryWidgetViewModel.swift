//
//  BatteryWidgetViewModel.swift
//  小哈电池Widget
//
//  ViewModel 业务逻辑层
//

import Foundation
import Combine

class BatteryWidgetViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var batteryNo: String = ""
    @Published var token: String = ""
    @Published var batteryPercentage: Int = 0
    @Published var lastUpdateTime: String = "未更新"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var testLog: String?
    @Published var isConfigured: Bool = false
    
    // MARK: - Private Properties
    private var networkService = BatteryNetworkService()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    private let userDefaultsKey = "BatteryWidgetConfig"
    private let batteryNoKey = "batteryNo"
    private let tokenKey = "token"
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// 加载保存的配置
    func loadConfiguration() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let config = try? JSONDecoder().decode(BatteryConfig.self, from: data) {
            DispatchQueue.main.async {
                self.batteryNo = config.batteryNo
                self.token = config.token
                self.isConfigured = !config.batteryNo.isEmpty && !config.token.isEmpty
            }
        }
    }
    
    /// 保存配置
    func saveConfiguration(batteryNo: String, token: String) {
        self.batteryNo = batteryNo
        self.token = token
        
        let config = BatteryConfig(batteryNo: batteryNo, token: token)
        if let encoded = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            DispatchQueue.main.async {
                self.isConfigured = true
                self.errorMessage = nil
            }
        }
    }
    
    /// 获取电池数据
    func fetchBatteryData() {
        guard !batteryNo.isEmpty && !token.isEmpty else {
            errorMessage = "未配置电池编号或Token"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        networkService.fetchBatteryData(
            batteryNo: batteryNo,
            token: token
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            
            switch completion {
            case .finished:
                break
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        } receiveValue: { [weak self] data in
            self?.updateBatteryData(data)
        }
        .store(in: &cancellables)
    }
    
    /// 测试连接
    func testConnection(batteryNo: String, token: String) {
        guard !batteryNo.isEmpty && !token.isEmpty else {
            testLog = "❌ 错误：电池编号或Token为空"
            return
        }
        
        isLoading = true
        testLog = "📡 开始测试连接...\n"
        
        networkService.testConnection(
            batteryNo: batteryNo,
            token: token
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            
            switch completion {
            case .finished:
                break
            case .failure(let error):
                self?.testLog?.append("❌ 测试失败: \(error.localizedDescription)\n")
            }
        } receiveValue: { [weak self] log in
            self?.testLog = log
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // 可以在这里添加额外的绑定逻辑
    }
    
    private func updateBatteryData(_ data: BatteryData) {
        self.batteryPercentage = data.batteryLife
        self.lastUpdateTime = formatDate(data.reportTime)
    }
    
    private func formatDate(_ dateString: String) -> String {
        // 尝试多种日期格式
        let dateFormatters = [
            createDateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss"),
            createDateFormatter(format: "yyyy-MM-dd HH:mm:ss"),
            createDateFormatter(format: "M/d HH:mm")
        ]
        
        for formatter in dateFormatters {
            if let date = formatter.date(from: dateString) {
                let displayFormatter = createDateFormatter(format: "M/d HH:mm")
                return displayFormatter.string(from: date)
            }
        }
        
        // 如果是时间戳
        if let timestamp = TimeInterval(dateString) {
            let date = Date(timeIntervalSince1970: timestamp / 1000)
            let formatter = createDateFormatter(format: "M/d HH:mm")
            return formatter.string(from: date)
        }
        
        return dateString
    }
    
    private func createDateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.timeZone = TimeZone.current
        return formatter
    }
}

// MARK: - Data Models
struct BatteryConfig: Codable {
    let batteryNo: String
    let token: String
}

struct BatteryData {
    let batteryLife: Int
    let reportTime: String
}

// MARK: - API Response Models
struct PreparamsResponse: Codable {
    let data: PreparamsData
}

struct PreparamsData: Codable {
    let url: String
    let body: String
    let headers: [String: String]
}

struct DecodeResponse: Codable {
    let data: DecodeData
}

struct DecodeData: Codable {
    let data: BatteryResponseData
}

struct BatteryResponseData: Codable {
    let bindBatteries: [BatteryInfo]
}

struct BatteryInfo: Codable {
    let batteryLife: Int
    let reportTime: String
}
