//
//  WidgetViews.swift
//  BTCWidget
//
//  Created by Bitcoin Monitoring on 2025/10/31.
//

import SwiftUI
import WidgetKit

// 小尺寸小组件视图
struct SmallWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 币种信息
            HStack {
                Image(systemName: entry.symbol.systemImageName)
                    .foregroundColor(entry.symbol.color)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(entry.symbol.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Spacer()
            
            // 价格信息
            VStack(alignment: .leading, spacing: 4) {
                Text("$\(formatPrice(entry.price))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                if let change = entry.changePercent {
                    HStack(spacing: 4) {
                        Image(systemName: change >= 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                            .font(.system(size: 8))
                            .foregroundColor(change >= 0 ? .green : .red)
                        
                        Text("\(change >= 0 ? "+" : "")\(String(format: "%.2f", change))%")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(change >= 0 ? .green : .red)
                    }
                }
            }
        }
        .padding(.all, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// 中等尺寸小组件视图
struct MediumWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // 左侧：币种图标和信息
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: entry.symbol.systemImageName)
                        .foregroundColor(entry.symbol.color)
                        .font(.system(size: 24, weight: .semibold))
                    
                    Text(entry.symbol.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("当前价格")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("$\(formatPrice(entry.price))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                
                Spacer()
            }
            
            // 右侧：变化信息和更新时间
            VStack(alignment: .trailing, spacing: 12) {
                if let change = entry.changePercent {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("24小时变化")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 6) {
                            Image(systemName: change >= 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                                .font(.system(size: 12))
                                .foregroundColor(change >= 0 ? .green : .red)
                            
                            Text("\(change >= 0 ? "+" : "")\(String(format: "%.2f", change))%")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(change >= 0 ? .green : .red)
                        }
                    }
                }
                
                Spacer()
                
                // 更新时间
                VStack(alignment: .trailing, spacing: 2) {
                    Text("更新时间")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(formatTime(entry.date))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.all, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// 大尺寸小组件视图
struct LargeWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 16) {
            // 顶部：标题和币种选择器
            HStack {
                HStack {
                    Image(systemName: entry.symbol.systemImageName)
                        .foregroundColor(entry.symbol.color)
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text("比特币价格监控")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // 当前时间
                Text(formatTime(entry.date))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // 主要价格信息区域
            VStack(spacing: 20) {
                // 币种和价格
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.symbol.fullName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(entry.symbol.displayName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("当前价格")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("$\(formatPrice(entry.price))")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                
                // 变化信息
                if let change = entry.changePercent {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("24小时变化")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 8) {
                                Image(systemName: change >= 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(change >= 0 ? .green : .red)
                                
                                Text("\(change >= 0 ? "+" : "")\(String(format: "%.2f", change))%")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(change >= 0 ? .green : .red)
                            }
                        }
                        
                        Spacer()
                        
                        // 状态指示器
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("市场状态")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 8, height: 8)
                                
                                Text("实时更新")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // 底部信息
            HStack {
                Text("数据来源: Binance API")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("每30秒更新")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.all, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - 辅助函数

private func formatPrice(_ price: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 4
    formatter.groupingSeparator = ","
    formatter.usesGroupingSeparator = true
    
    return formatter.string(from: NSNumber(value: price)) ?? String(format: "%.4f", price)
}

private func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

// MARK: - 币种扩展

extension CryptoSymbol {
    var color: Color {
        switch self {
        case .btc: return .orange
        case .eth: return .blue
        case .bnb: return .yellow
        case .sol: return .purple
        case .ada: return .blue
        case .xrp: return .indigo
        case .dot: return .pink
        case .doge: return .yellow
        case .avax: return .red
        case .matic: return .purple
        }
    }
    
    var fullName: String {
        switch self {
        case .btc: return "Bitcoin"
        case .eth: return "Ethereum"
        case .bnb: return "BNB"
        case .sol: return "Solana"
        case .ada: return "Cardano"
        case .xrp: return "XRP"
        case .dot: return "Polkadot"
        case .doge: return "Dogecoin"
        case .avax: return "Avalanche"
        case .matic: return "Polygon"
        }
    }
}

// MARK: - 预览

#Preview("小组件", as: .systemSmall) {
    BTCWidget()
} timeline: {
    SimpleEntry(date: .now, symbol: .btc, price: 67234.56, changePercent: 2.34)
}

#Preview("中等组件", as: .systemMedium) {
    BTCWidget()
} timeline: {
    SimpleEntry(date: .now, symbol: .eth, price: 2456.78, changePercent: -1.23)
}

#Preview("大组件", as: .systemLarge) {
    BTCWidget()
} timeline: {
    SimpleEntry(date: .now, symbol: .sol, price: 156.78, changePercent: 5.67)
}