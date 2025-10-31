# macOS 小组件配置指南

## 概述
我已经为您的 Bitcoin Monitoring 项目创建了完整的 macOS 小组件扩展。小组件将显示实时的比特币价格信息，并支持小、中、大三种尺寸。

## 已创建的文件

### 小组件扩展文件 (`BTCWidget/`)
- `BTCWidget.swift` - 主要小组件实现
- `BTCWidgetBundle.swift` - 小组件包入口点
- `WidgetViews.swift` - 小组件UI视图（支持3种尺寸）
- `BTCWidget.entitlements` - 小组件权限配置
- `Info.plist` - 小组件配置信息

### 共享数据管理 (`test1/`)
- `WidgetDataManager.swift` - 主应用与小组件间数据共享管理器

## 功能特性

### 小组件尺寸支持
1. **小尺寸** - 显示币种图标、名称和当前价格
2. **中等尺寸** - 增加24小时变化百分比和更新时间
3. **大尺寸** - 完整的价格仪表板，包含详细信息和状态

### 数据同步
- 主应用更新价格时自动同步到小组件
- 使用 App Groups 进行安全的数据共享
- 自动每30秒刷新价格

### 视觉设计
- 支持深色和浅色模式
- 每种加密货币都有对应的颜色主题
- 清晰的价格格式化显示（千分位分隔符）
- 涨跌指示器（绿色上涨，红色下跌）

## Xcode 项目配置

由于您的项目使用较新的 Xcode 项目格式，请按以下步骤在 Xcode 中配置：

### 1. 添加小组件扩展目标
1. 在 Xcode 中打开项目
2. 点击项目导航器中的项目名称
3. 点击 "+" 按钮添加新目标
4. 选择 "Widget Extension"
5. 填写以下信息：
   - Product Name: `BTCWidget`
   - Bundle Identifier: `com.yourcompany.Bitcoin-Monitoring.BTCWidget`
   - 选择 "Include Configuration Intent": 否

### 2. 配置 App Groups
1. 选择主应用目标 "Bitcoin Monitoring"
2. 进入 "Signing & Capabilities" 选项卡
3. 点击 "+ Capability" 添加 "App Groups"
4. 添加组标识符：`group.bitcoin.monitoring.widget`

5. 重复步骤1-4为小组件目标配置相同的 App Groups

### 3. 添加文件到目标
1. 将 `BTCWidget/` 文件夹中的所有文件添加到小组件目标
2. 将 `WidgetDataManager.swift` 同时添加到主应用和小组件目标
3. 确保共享的模型文件（如 `CryptoSymbol.swift`）也添加到小组件目标

### 4. 配置部署目标
- 确保小组件扩展的部署目标与主应用一致（推荐 macOS 14.0+）

## 使用说明

### 添加小组件到桌面
1. 编译并运行应用
2. 在 macOS 桌面右键点击
3. 选择 "编辑小组件"
4. 找到 "比特币价格" 小组件并添加

### 小组件功能
- **实时价格显示**: 显示当前选中币种的实时价格
- **自动刷新**: 每30秒自动更新价格数据
- **多币种支持**: 支持 BTC, ETH, BNB, SOL 等多种加密货币
- **视觉指示器**: 显示24小时价格变化趋势

## 技术实现

### 数据流
1. 主应用的 `PriceManager` 获取价格数据
2. 更新时调用 `WidgetDataManager.shared.saveWidgetData()`
3. 数据保存到共享的 `UserDefaults(suiteName: "group.bitcoin.monitoring.widget")`
4. 调用 `WidgetCenter.shared.reloadAllTimelines()` 刷新小组件

### 性能优化
- 使用 `@MainActor` 确保UI更新在主线程
- 异步数据获取避免阻塞UI
- 合理的刷新频率避免过度消耗资源

## 故障排除

### 小组件不显示数据
1. 检查 App Groups 配置是否正确
2. 确保权限文件 (.entitlements) 配置正确
3. 验证 Bundle Identifier 设置

### 数据不同步
1. 检查 `WidgetDataManager` 是否正确导入
2. 确认主应用调用了 `updateWidgetData()`
3. 查看控制台日志中的错误信息

### 编译错误
1. 确保所有必要的文件都添加到正确的目标
2. 检查 WidgetKit 框架是否正确导入
3. 验证部署目标版本兼容性

## 未来扩展

### 可能的增强功能
- 多币种价格对比显示
- 价格警报集成
- 历史价格图表
- 自定义刷新间隔
- 点击小组件打开主应用特定页面

---

配置完成后，您将拥有一个功能完整的 macOS 桌面小组件，可以直观地显示比特币和其他加密货币的实时价格信息，有效替代币安、OKX 等第三方小组件。