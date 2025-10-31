//
//  WidgetDataManager.swift
//  Bitcoin Monitoring
//
//  Created by Bitcoin Monitoring on 2025/10/31.
//

import Foundation
import WidgetKit

// 小组件数据结构
struct WidgetData: Codable {
    let symbol: CryptoSymbol
    let price: Double
    let changePercent: Double?
    let lastUpdated: Date
    
    init(symbol: CryptoSymbol, price: Double, changePercent: Double? = nil) {
        self.symbol = symbol
        self.price = price
        self.changePercent = changePercent
        self.lastUpdated = Date()
    }
}

// 小组件数据管理器
@MainActor
class WidgetDataManager: ObservableObject {
    static let shared = WidgetDataManager()
    
    private let suiteName = "group.bitcoin.monitoring.widget"
    private let dataKey = "widget_data"
    
    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: suiteName)
    }
    
    private init() {}
    
    // 保存数据给小组件使用
    func saveWidgetData(_ data: WidgetData) {
        guard let userDefaults = userDefaults else {
            print("❌ [WidgetDataManager] 无法访问共享 UserDefaults")
            return
        }
        
        do {
            let encodedData = try JSONEncoder().encode(data)
            userDefaults.set(encodedData, forKey: dataKey)
            
            // 通知小组件更新
            WidgetCenter.shared.reloadAllTimelines()
            
            print("✅ [WidgetDataManager] 已保存小组件数据: \(data.symbol.displayName) $\(String(format: "%.4f", data.price))")
        } catch {
            print("❌ [WidgetDataManager] 保存小组件数据失败: \(error)")
        }
    }
    
    // 从共享存储获取数据
    nonisolated func getCurrentData() async -> WidgetData {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            print("❌ [WidgetDataManager] 无法访问共享 UserDefaults，使用默认数据")
            return WidgetData(symbol: .btc, price: 0.0)
        }
        
        guard let data = userDefaults.data(forKey: dataKey) else {
            print("ℹ️ [WidgetDataManager] 未找到小组件数据，使用默认数据")
            return WidgetData(symbol: .btc, price: 0.0)
        }
        
        do {
            let widgetData = try JSONDecoder().decode(WidgetData.self, from: data)
            return widgetData
        } catch {
            print("❌ [WidgetDataManager] 解析小组件数据失败: \(error)，使用默认数据")
            return WidgetData(symbol: .btc, price: 0.0)
        }
    }
    
    // 更新小组件显示
    func refreshWidget() {
        WidgetCenter.shared.reloadAllTimelines()
        print("🔄 [WidgetDataManager] 已请求刷新小组件")
    }
}

// MARK: - 扩展现有的 PriceManager 以支持小组件

extension PriceManager {
    // 更新小组件数据
    func updateWidgetData() {
        let widgetData = WidgetData(
            symbol: selectedSymbol,
            price: currentPrice,
            changePercent: generateMockChangePercent() // 暂时使用模拟数据
        )
        
        WidgetDataManager.shared.saveWidgetData(widgetData)
    }
    
    // 生成模拟的变化百分比（实际项目中应该从API获取）
    private func generateMockChangePercent() -> Double {
        // 这里应该从实际的API获取24小时变化数据
        // 为了演示，我们生成一个随机的变化百分比
        return Double.random(in: -10...10)
    }
}