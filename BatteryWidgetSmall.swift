//
//  BatteryWidgetSmall.swift
//  小哈电池Widget
//
//  iOS Widget 小组件 (锁屏和主屏)
//

import SwiftUI
import WidgetKit

// MARK: - Widget Bundle
@main
struct BatteryWidgetBundle: WidgetBundle {
    var body: some Widget {
        SmallBatteryWidget()
        LargeBatteryWidget()
    }
}

// MARK: - Small Widget (锁屏)
struct SmallBatteryWidget: Widget {
    let kind: String = "SmallBatteryWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SmallWidgetProvider()) { entry in
            SmallBatteryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("电池电量")
        .description("显示小哈电池实时电量")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Large Widget (主屏)
struct LargeBatteryWidget: Widget {
    let kind: String = "LargeBatteryWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LargeWidgetProvider()) { entry in
            LargeBatteryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("电池监控")
        .description("显示小哈电池电量和详细信息")
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - Data Entry
struct BatteryWidgetEntry: TimelineEntry {
    let date: Date
    let batteryPercentage: Int
    let batteryNo: String
    let updateTime: String
    let isLoading: Bool
    let errorMessage: String?
}

// MARK: - Small Widget Provider
struct SmallWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> BatteryWidgetEntry {
        BatteryWidgetEntry(
            date: Date(),
            batteryPercentage: 75,
            batteryNo: "8903115649",
            updateTime: "加载中...",
            isLoading: true,
            errorMessage: nil
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (BatteryWidgetEntry) -> ()) {
        let entry = BatteryWidgetEntry(
            date: Date(),
            batteryPercentage: 75,
            batteryNo: "8903115649",
            updateTime: "12/15 14:30",
            isLoading: false,
            errorMessage: nil
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<BatteryWidgetEntry>) -> ()) {
        // 从UserDefaults读取配置
        let userDefaults = UserDefaults(suiteName: "group.com.xiaoha.batterywidget") ?? UserDefaults.standard
        
        guard let configData = userDefaults.data(forKey: "BatteryWidgetConfig"),
              let config = try? JSONDecoder().decode(BatteryConfig.self, from: configData) else {
            let entry = BatteryWidgetEntry(
                date: Date(),
                batteryPercentage: 0,
                batteryNo: "",
                updateTime: "未配置",
                isLoading: false,
                errorMessage: "请先在应用中配置"
            )
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
            completion(timeline)
            return
        }
        
        // 异步获取电池数据
        let networkService = BatteryNetworkService()
        
        var cancellable: AnyCancellable?
        cancellable = networkService.fetchBatteryData(
            batteryNo: config.batteryNo,
            token: config.token
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                let entry = BatteryWidgetEntry(
                    date: Date(),
                    batteryPercentage: 0,
                    batteryNo: config.batteryNo,
                    updateTime: "加载失败",
                    isLoading: false,
                    errorMessage: error.errorDescription
                )
                let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300)))
                completion(timeline)
            }
        } receiveValue: { batteryData in
            let entry = BatteryWidgetEntry(
                date: Date(),
                batteryPercentage: batteryData.batteryLife,
                batteryNo: config.batteryNo,
                updateTime: formatDate(batteryData.reportTime),
                isLoading: false,
                errorMessage: nil
            )
            // 每5分钟刷新一次
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300)))
            completion(timeline)
        }
    }
}

// MARK: - Large Widget Provider
struct LargeWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> BatteryWidgetEntry {
        BatteryWidgetEntry(
            date: Date(),
            batteryPercentage: 75,
            batteryNo: "8903115649",
            updateTime: "加载中...",
            isLoading: true,
            errorMessage: nil
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (BatteryWidgetEntry) -> ()) {
        let entry = BatteryWidgetEntry(
            date: Date(),
            batteryPercentage: 75,
            batteryNo: "8903115649",
            updateTime: "12/15 14:30",
            isLoading: false,
            errorMessage: nil
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<BatteryWidgetEntry>) -> ()) {
        // 从AppGroup读取配置（与主应用共享）
        let userDefaults = UserDefaults(suiteName: "group.com.xiaoha.batterywidget") ?? UserDefaults.standard
        
        guard let configData = userDefaults.data(forKey: "BatteryWidgetConfig"),
              let config = try? JSONDecoder().decode(BatteryConfig.self, from: configData) else {
            let entry = BatteryWidgetEntry(
                date: Date(),
                batteryPercentage: 0,
                batteryNo: "",
                updateTime: "未配置",
                isLoading: false,
                errorMessage: "请先在应用中配置"
            )
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
            completion(timeline)
            return
        }
        
        let networkService = BatteryNetworkService()
        
        var cancellable: AnyCancellable?
        cancellable = networkService.fetchBatteryData(
            batteryNo: config.batteryNo,
            token: config.token
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                let entry = BatteryWidgetEntry(
                    date: Date(),
                    batteryPercentage: 0,
                    batteryNo: config.batteryNo,
                    updateTime: "加载失败",
                    isLoading: false,
                    errorMessage: error.errorDescription
                )
                let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300)))
                completion(timeline)
            }
        } receiveValue: { batteryData in
            let entry = BatteryWidgetEntry(
                date: Date(),
                batteryPercentage: batteryData.batteryLife,
                batteryNo: config.batteryNo,
                updateTime: formatDate(batteryData.reportTime),
                isLoading: false,
                errorMessage: nil
            )
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300)))
            completion(timeline)
        }
    }
}

// MARK: - Small Widget Entry View
struct SmallBatteryWidgetEntryView: View {
    var entry: SmallWidgetProvider.Entry
    
    var body: some View {
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
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("电池电量")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(entry.batteryPercentage)%")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // 环形进度
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 3)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(entry.batteryPercentage) / 100)
                            .stroke(Color.white, lineWidth: 3)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(entry.batteryPercentage)%")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 60, height: 60)
                }
                
                if let errorMessage = entry.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 10))
                        .foregroundColor(.red)
                        .lineLimit(1)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 9))
                        Text(entry.updateTime)
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding()
        }
    }
}

// MARK: - Large Widget Entry View
struct LargeBatteryWidgetEntryView: View {
    var entry: LargeWidgetProvider.Entry
    
    var body: some View {
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
            
            VStack(spacing: 20) {
                HStack {
                    Text("小哈电池监控")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if entry.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                }
                
                // 大型进度圆环
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(entry.batteryPercentage) / 100)
                            .stroke(Color.white, lineWidth: 8)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 4) {
                            Text("\(entry.batteryPercentage)%")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("电量")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .frame(height: 180)
                }
                
                // 详细信息
                VStack(spacing: 12) {
                    HStack {
                        Text("电池编号")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text(entry.batteryNo)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("更新时间")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text(entry.updateTime)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    if let errorMessage = entry.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 11))
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Helper Functions
private func formatDate(_ dateString: String) -> String {
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

#Preview {
    SmallBatteryWidgetEntryView(entry: BatteryWidgetEntry(
        date: Date(),
        batteryPercentage: 85,
        batteryNo: "8903115649",
        updateTime: "12/15 14:30",
        isLoading: false,
        errorMessage: nil
    ))
}
