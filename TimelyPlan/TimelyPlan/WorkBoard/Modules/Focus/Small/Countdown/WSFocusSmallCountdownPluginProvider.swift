//
//  WSFocusSmallCountdownPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 专注·小·倒计时。展示一次倒计时专注的入口与状态。
class WSFocusSmallCountdownPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .focusSmallCountdown
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSFocusSmallCountdownContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSFocusSmallCountdownContentInteractor(plugin: plugin, context: context)
    }
}

// MARK: - 内容交互器

class WSFocusSmallCountdownContentInteractor: WSPluginContentInteractor, SettingAgentObserver {
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        /// 观察者由 `SettingAgent` 弱引用持有，无需手动移除
        FocusState.shared.addObserver(self, forKey: .countdownConfig)
    }
    
    // MARK: - SettingAgentObserver
    /// 默认倒计时配置变化：重新取数并通知内容视图刷新
    func settingAgentDidChangeValue(for keyName: String) {
        guard keyName == FocusState.SettingKey.countdownConfig.name else {
            return
        }
        
        pluginDataDidChange()
    }
    
    // MARK: - 取数
    /// 使用默认倒计时配置
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let config = FocusState.shared.countdownConfig
        completion(WSFocusCountdownDataItem(config: config))
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：使用默认倒计时配置
    override func previewDataItem() -> WSPluginDataItem? {
        var config = FocusCountdownConfig()
        config.duration = TimeInterval(135 * SECONDS_PER_MINUTE)
        return WSFocusCountdownDataItem(config: config)
    }
    
    // MARK: - 主操作
    /// 点击开始按钮：开启默认倒计时专注
    override func performPrimaryAction() {
        let config = FocusState.shared.countdownConfig
        let timer = FocusSystemCountdownTimer(config: config)
        FocusPresenter.startFocus(with: timer)
    }
}
