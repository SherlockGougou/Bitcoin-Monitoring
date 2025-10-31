//
//  BTCWidget.swift
//  BTCWidget
//
//  Created by Bitcoin Monitoring on 2025/10/31.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), symbol: .btc, price: 67234.56, changePercent: 2.34)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), symbol: .btc, price: 67234.56, changePercent: 2.34)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            // 获取当前选中的币种和价格数据
            let widgetData = await WidgetDataManager.shared.getCurrentData()
            let entry = SimpleEntry(
                date: Date(),
                symbol: widgetData.symbol,
                price: widgetData.price,
                changePercent: widgetData.changePercent
            )
            
            // 设置下次更新时间（30秒后）
            let nextUpdate = Calendar.current.date(byAdding: .second, value: 30, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let symbol: CryptoSymbol
    let price: Double
    let changePercent: Double?
}

struct BTCWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct BTCWidget: Widget {
    let kind: String = "BTCWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BTCWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("比特币价格")
        .description("实时查看比特币和其他加密货币价格")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    BTCWidget()
} timeline: {
    SimpleEntry(date: .now, symbol: .btc, price: 67234.56, changePercent: 2.34)
    SimpleEntry(date: .now, symbol: .eth, price: 2456.78, changePercent: -1.23)
}