#!/bin/bash

# Bitcoin Monitoring 小组件配置脚本
# 使用方法: ./setup_widget.sh

echo "🚀 开始配置 Bitcoin Monitoring 小组件..."

# 检查是否在正确的目录
if [ ! -f "Bitcoin Monitoring.xcodeproj/project.pbxproj" ]; then
    echo "❌ 错误: 请在项目根目录运行此脚本"
    exit 1
fi

echo "📁 检查小组件文件..."

# 检查小组件文件是否存在
WIDGET_FILES=(
    "BTCWidget/BTCWidget.swift"
    "BTCWidget/BTCWidgetBundle.swift" 
    "BTCWidget/WidgetViews.swift"
    "BTCWidget/BTCWidget.entitlements"
    "BTCWidget/Info.plist"
    "test1/WidgetDataManager.swift"
)

for file in "${WIDGET_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file 存在"
    else
        echo "❌ $file 不存在"
        exit 1
    fi
done

echo "🔧 验证权限配置..."

# 检查主应用权限文件
if grep -q "group.bitcoin.monitoring.widget" "test1/test1.entitlements"; then
    echo "✅ 主应用 App Groups 配置正确"
else
    echo "❌ 主应用 App Groups 配置缺失"
    exit 1
fi

# 检查小组件权限文件
if grep -q "group.bitcoin.monitoring.widget" "BTCWidget/BTCWidget.entitlements"; then
    echo "✅ 小组件 App Groups 配置正确"
else
    echo "❌ 小组件 App Groups 配置缺失"
    exit 1
fi

echo "📝 检查代码集成..."

# 检查 PriceManager 是否包含小组件更新代码
if grep -q "updateWidgetData" "test1/PriceManager.swift"; then
    echo "✅ PriceManager 已集成小组件数据同步"
else
    echo "❌ PriceManager 缺失小组件数据同步代码"
    exit 1
fi

# 检查是否导入了 WidgetKit
if grep -q "import WidgetKit" "test1/PriceManager.swift"; then
    echo "✅ PriceManager 已导入 WidgetKit"
else
    echo "❌ PriceManager 缺失 WidgetKit 导入"
    exit 1
fi

echo ""
echo "🎉 所有文件配置检查通过！"
echo ""
echo "📋 接下来在 Xcode 中完成以下步骤:"
echo ""
echo "1. 📱 添加小组件扩展目标:"
echo "   - 打开 Bitcoin Monitoring.xcodeproj"
echo "   - 点击项目 → 添加目标 → Widget Extension"
echo "   - Product Name: BTCWidget"
echo "   - Bundle ID: com.yourcompany.Bitcoin-Monitoring.BTCWidget"
echo ""
echo "2. 🔐 配置 App Groups:"
echo "   - 选择主应用目标 → Signing & Capabilities → 添加 App Groups"
echo "   - 组ID: group.bitcoin.monitoring.widget"
echo "   - 为小组件目标重复此步骤"
echo ""
echo "3. 📁 添加文件到目标:"
echo "   - 将 BTCWidget/ 文件夹中的文件添加到小组件目标"
echo "   - 将 WidgetDataManager.swift 添加到两个目标"
echo "   - 将共享模型文件添加到小组件目标"
echo ""
echo "4. ⚙️ 配置部署目标:"
echo "   - 确保小组件扩展部署目标 ≥ macOS 14.0"
echo ""
echo "5. 🏗️ 编译和测试:"
echo "   - 编译项目"
echo "   - 运行主应用"
echo "   - 在桌面添加小组件"
echo ""
echo "📚 详细说明请查看 WIDGET_SETUP.md 文件"
echo ""
echo "✨ 配置完成后，您将拥有一个现代化的 macOS 加密货币价格小组件！"