//
//  BTCMenuBarApp.swift
//  test1
//
//  Created by Mark on 2025/10/28.
//

import SwiftUI
import AppKit
import Combine

// macOS菜单栏应用主类
@MainActor
class BTCMenuBarApp: NSObject, ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var priceManager = PriceManager()
    private var appSettings = AppSettings()
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        setupMenuBar()
        setupConfigurationObservers()
    }

    // 设置配置观察者
    private func setupConfigurationObservers() {
        // 监听刷新间隔配置变化
        appSettings.$refreshInterval
            .sink { [weak self] newInterval in
                self?.priceManager.updateRefreshInterval(newInterval)
            }
            .store(in: &cancellables)
    }

    // 设置菜单栏
    private func setupMenuBar() {
        // 创建状态栏项目
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let statusItem = statusItem else {
            print("❌ 无法创建状态栏项目")
            return
        }

        guard let button = statusItem.button else {
            print("❌ 无法获取状态栏按钮")
            return
        }

        // 设置BTC图标和标题
        updateMenuBarTitle(price: 0.0)
        button.action = #selector(menuBarClicked)
        button.target = self

        // 监听价格变化
        priceManager.$currentPrice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] price in
                self?.updateMenuBarTitle(price: price)
            }
            .store(in: &cancellables)
    }

    // 更新菜单栏标题
    private func updateMenuBarTitle(price: Double) {
        DispatchQueue.main.async {
            guard let button = self.statusItem?.button else { return }

            // 创建BTC图标
            let btcImage = NSImage(systemSymbolName: "bitcoinsign.circle.fill", accessibilityDescription: "BTC")
            btcImage?.size = NSSize(width: 16, height: 16)

            // 设置图标
            button.image = btcImage

            // 根据状态设置标题
            if price == 0.0 {
                if self.priceManager.isFetching {
                    button.title = " 更新中..."
                } else if self.priceManager.lastError != nil {
                    button.title = " 错误"
                } else {
                    button.title = " 加载中..."
                }
            } else {
                button.title = String(format: " $%.2f", price)
            }
        }
    }

    // 菜单栏点击事件
    @objc private func menuBarClicked() {
        guard let button = statusItem?.button else {
            print("❌ 无法获取状态栏按钮")
            return
        }
        showMenu(from: button)
    }

    // 显示菜单
    private func showMenu(from view: NSView) {
        let menu = NSMenu()

        // 添加价格信息项（带BTC图标）
        let priceItem = NSMenuItem(title: priceManager.formattedPrice, action: nil, keyEquivalent: "")
        if let btcImage = NSImage(systemSymbolName: "bitcoinsign.circle.fill", accessibilityDescription: "BTC") {
            btcImage.size = NSSize(width: 16, height: 16)
            priceItem.image = btcImage
        }
        priceItem.isEnabled = false
        menu.addItem(priceItem)

        // 如果有错误，显示错误信息（带错误图标）
        if let errorMessage = priceManager.errorMessage {
            let errorItem = NSMenuItem(title: "错误: \(errorMessage)", action: nil, keyEquivalent: "")
            if let errorImage = NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: "错误") {
                errorImage.size = NSSize(width: 16, height: 16)
                errorItem.image = errorImage
            }
            errorItem.isEnabled = false
            menu.addItem(errorItem)
            menu.addItem(NSMenuItem.separator())
        }

        // 添加最后更新时间（带时钟图标）
        let timeItem = NSMenuItem(title: "上次更新: \(getCurrentTime())", action: nil, keyEquivalent: "")
        if let clockImage = NSImage(systemSymbolName: "clock", accessibilityDescription: "时间") {
            clockImage.size = NSSize(width: 16, height: 16)
            timeItem.image = clockImage
        }
        timeItem.isEnabled = false
        menu.addItem(timeItem)

        menu.addItem(NSMenuItem.separator())

        // 添加刷新按钮（带刷新图标）
        let refreshTitle = priceManager.isFetching ? "刷新中..." : "刷新价格"
        let refreshItem = NSMenuItem(title: refreshTitle, action: #selector(refreshPrice), keyEquivalent: "r")
        if let refreshImage = NSImage(systemSymbolName: priceManager.isFetching ? "hourglass" : "arrow.clockwise", accessibilityDescription: "刷新") {
            refreshImage.size = NSSize(width: 16, height: 16)
            refreshItem.image = refreshImage
        }
        refreshItem.target = self
        refreshItem.isEnabled = !priceManager.isFetching
        menu.addItem(refreshItem)

        // 添加刷新设置子菜单
        let refreshSettingsItem = NSMenuItem(title: "刷新设置", action: nil, keyEquivalent: "")
        if let settingsImage = NSImage(systemSymbolName: "timer", accessibilityDescription: "刷新设置") {
            settingsImage.size = NSSize(width: 16, height: 16)
            refreshSettingsItem.image = settingsImage
        }

        let refreshSettingsMenu = NSMenu()
        let currentInterval = priceManager.getCurrentRefreshInterval()

        // 为每个刷新间隔创建菜单项
        for interval in RefreshInterval.allCases {
            let isCurrent = (interval == currentInterval)
            let item = NSMenuItem(
                title: interval.displayTextWithMark(isCurrent: isCurrent),
                action: #selector(selectRefreshInterval(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = interval
            item.isEnabled = !isCurrent // 当前选中的项不能再次点击

            refreshSettingsMenu.addItem(item)
        }

        refreshSettingsItem.submenu = refreshSettingsMenu
        menu.addItem(refreshSettingsItem)

        menu.addItem(NSMenuItem.separator())

        // 添加GitHub按钮（带GitHub图标）
        let checkUpdateItem = NSMenuItem(title: "GitHub", action: #selector(checkForUpdates), keyEquivalent: "")
        if let updateImage = NSImage(systemSymbolName: "star.circle", accessibilityDescription: "GitHub") {
            updateImage.size = NSSize(width: 16, height: 16)
            checkUpdateItem.image = updateImage
        }
        checkUpdateItem.target = self
        menu.addItem(checkUpdateItem)

        // 添加关于按钮（带信息图标）
        let aboutItem = NSMenuItem(title: "关于", action: #selector(showAbout), keyEquivalent: "")
        if let infoImage = NSImage(systemSymbolName: "info.circle", accessibilityDescription: "关于") {
            infoImage.size = NSSize(width: 16, height: 16)
            aboutItem.image = infoImage
        }
        aboutItem.target = self
        menu.addItem(aboutItem)

        // 添加退出按钮（带退出图标）
        let quitItem = NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q")
        if let quitImage = NSImage(systemSymbolName: "power", accessibilityDescription: "退出") {
            quitImage.size = NSSize(width: 16, height: 16)
            quitItem.image = quitImage
        }
        quitItem.target = self
        menu.addItem(quitItem)

        // 安全显示菜单
        guard let statusItem = statusItem,
              let button = statusItem.button else {
            print("❌ 无法显示菜单 - 状态栏项目不可用")
            return
        }

        statusItem.menu = menu
        button.performClick(nil)
        statusItem.menu = nil
    }

    // 获取当前时间字符串
    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: Date())
    }

    // 刷新价格
    @objc private func refreshPrice() {
        Task {
            await priceManager.refreshPrice()
        }
    }

    // 选择刷新间隔
    @objc private func selectRefreshInterval(_ sender: NSMenuItem) {
        guard let interval = sender.representedObject as? RefreshInterval else {
            return
        }

        // 保存配置到UserDefaults
        appSettings.saveRefreshInterval(interval)

        // 立即应用新的刷新间隔
        priceManager.updateRefreshInterval(interval)

        print("✅ 刷新间隔已更新为: \(interval.displayText)")
    }

    // 显示关于对话框
    @objc private func showAbout() {
        let currentInterval = priceManager.getCurrentRefreshInterval()

        // 获取应用版本信息
        let version = getAppVersion()
        let alert = NSAlert()
        alert.messageText = "BTC价格监控器 v\(version)"
        alert.informativeText = """
        🚀 一款 macOS 原生菜单栏应用，用于实时显示BTC价格

        ✨ 功能特性：
        • 实时显示BTC/USDT价格
        • 可配置刷新间隔（当前：\(currentInterval.displayText)）
        • 支持手动刷新 (Cmd+R)
        • 智能错误重试机制
        • 优雅的SF Symbols图标
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }

    // 打开GitHub页面
    @objc private func checkForUpdates() {
        let githubURL = "https://github.com/jiayouzl/Bitcoin-Monitoring"

        // 确保URL有效
        guard let url = URL(string: githubURL) else {
            print("❌ 无效的URL: \(githubURL)")
            return
        }

        // 使用默认浏览器打开URL
        NSWorkspace.shared.open(url)

        print("✅ 已在浏览器中打开GitHub页面: \(githubURL)")
    }

    // 获取应用版本信息
    /// - Returns: 版本号字符串，格式为 "主版本号.次版本号.修订号"
    private func getAppVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "未知版本"
        }

        return version
    }

    // 退出应用
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
