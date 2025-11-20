//
//  BatteryNetworkService.swift
//  小哈电池Widget
//
//  网络请求服务层
//

import Foundation
import Combine

class BatteryNetworkService {
    // MARK: - Constants
    private let baseURL = "https://xiaoha.linkof.link"
    private let preparamsEndpoint = "/preparams"
    private let decodeEndpoint = "/decode"
    
    // MARK: - Properties
    private let session: URLSession
    
    // MARK: - Initialization
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Public Methods
    
    /// 获取电池数据的完整流程
    func fetchBatteryData(batteryNo: String, token: String) -> AnyPublisher<BatteryData, NetworkError> {
        // 步骤1: 获取预处理参数
        getPreparams(batteryNo: batteryNo, token: token)
            .flatMap { preparamsData in
                // 步骤2: 使用预处理参数获取加密数据
                self.getBatteryData(preparamsData: preparamsData)
            }
            .flatMap { encryptedData in
                // 步骤3: 解码电池数据
                self.decodeBatteryData(encryptedData: encryptedData)
            }
            .eraseToAnyPublisher()
    }
    
    /// 测试连接（详细日志）
    func testConnection(batteryNo: String, token: String) -> AnyPublisher<String, NetworkError> {
        var log = "🔍 API连接测试日志\n\n"
        
        return getPreparams(batteryNo: batteryNo, token: token)
            .flatMap { preparamsData -> AnyPublisher<(preparamsData: PreparamsData, log: String), NetworkError> in
                var updatedLog = log
                updatedLog += "✅ 步骤1: 获取预处理参数成功\n"
                updatedLog += "URL: \(preparamsData.url)\n"
                updatedLog += "Headers: \(preparamsData.headers)\n\n"
                
                return self.getBatteryData(preparamsData: preparamsData)
                    .map { encryptedData in
                        (preparamsData, updatedLog + "✅ 步骤2: 获取电池数据成功\n数据长度: \(encryptedData.count) bytes\n\n")
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { data -> AnyPublisher<String, NetworkError> in
                var updatedLog = data.log
                
                return self.decodeBatteryData(encryptedData: data.preparamsData.body.data(using: .utf8) ?? Data())
                    .map { batteryData in
                        updatedLog += "✅ 步骤3: 解码电池数据成功\n"
                        updatedLog += "电池电量: \(batteryData.batteryLife)%\n"
                        updatedLog += "报告时间: \(batteryData.reportTime)\n\n"
                        updatedLog += "✅ 测试完成！接口调用成功"
                        return updatedLog
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    /// 步骤1: 获取预处理参数
    private func getPreparams(batteryNo: String, token: String) -> AnyPublisher<PreparamsData, NetworkError> {
        var urlComponents = URLComponents(string: "\(baseURL)\(preparamsEndpoint)")!
        urlComponents.queryItems = [URLQueryItem(name: "batteryNo", value: batteryNo)]
        
        guard let url = urlComponents.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = token.data(using: .utf8)
        
        return session.dataTaskPublisher(for: request)
            .mapError { _ in NetworkError.networkError }
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.invalidResponse
                }
                return try JSONDecoder().decode(PreparamsResponse.self, from: data).data
            }
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                }
                return .decodingError
            }
            .eraseToAnyPublisher()
    }
    
    /// 步骤2: 获取电池数据
    private func getBatteryData(preparamsData: PreparamsData) -> AnyPublisher<Data, NetworkError> {
        guard let url = URL(string: preparamsData.url) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 添加headers
        for (key, value) in preparamsData.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        request.httpBody = preparamsData.body.data(using: .utf8)
        
        return session.dataTaskPublisher(for: request)
            .mapError { _ in NetworkError.networkError }
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.invalidResponse
                }
                return data
            }
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                }
                return .networkError
            }
            .eraseToAnyPublisher()
    }
    
    /// 步骤3: 解码电池数据
    private func decodeBatteryData(encryptedData: Data) -> AnyPublisher<BatteryData, NetworkError> {
        let url = URL(string: "\(baseURL)\(decodeEndpoint)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.httpBody = encryptedData
        
        return session.dataTaskPublisher(for: request)
            .mapError { _ in NetworkError.networkError }
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.invalidResponse
                }
                
                let decodeResponse = try JSONDecoder().decode(DecodeResponse.self, from: data)
                guard let batteryInfo = decodeResponse.data.data.bindBatteries.first else {
                    throw NetworkError.invalidResponse
                }
                
                return BatteryData(
                    batteryLife: batteryInfo.batteryLife,
                    reportTime: batteryInfo.reportTime
                )
            }
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                }
                return .decodingError
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Error Types
enum NetworkError: LocalizedError {
    case invalidURL
    case networkError
    case invalidResponse
    case decodingError
    case serverError(Int)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .networkError:
            return "网络连接失败，请检查网络"
        case .invalidResponse:
            return "服务器响应无效"
        case .decodingError:
            return "数据解析失败"
        case .serverError(let code):
            return "服务器错误 (\(code))"
        case .unknown:
            return "未知错误"
        }
    }
}
