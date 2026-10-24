//
//  WSFocusSmallPomodoroPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 专注·小·番茄钟。展示一次番茄钟专注的入口与状态。
class WSFocusSmallPomodoroPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .focusSmallPomodoro
    }
    
    /// 该组件注册的单元格类
    var cellClass: WSPluginCell.Type {
        return WSFocusSmallPomodoroPluginCell.self
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSFocusSmallPomodoroContentInteractor(plugin: plugin, context: context)
    }
}

// MARK: - 内容交互器

class WSFocusSmallPomodoroContentInteractor: WSPluginContentInteractor, SettingAgentObserver {
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        FocusState.shared.addObserver(self, forKey: .pomodoroConfig)
    }
    
    // MARK: - SettingAgentObserver
    /// 默认番茄钟配置变化：重新取数并通知内容视图刷新
    func settingAgentDidChangeValue(for keyName: String) {
        guard keyName == FocusState.SettingKey.pomodoroConfig.name else {
            return
        }
        
        pluginDataDidChange()
    }
    
    // MARK: - 取数
    /// 使用默认番茄钟配置
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let config = FocusState.shared.pomodoroConfig
        let dataItem = WSFocusPomodoroDataItem(config: config)
        completion(dataItem)
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：使用默认番茄钟配置
    override func previewDataItem() -> WSPluginDataItem? {
        return WSFocusPomodoroDataItem(config: FocusPomodoroConfig())
    }
    
    // MARK: - 主操作
    /// 点击开始按钮：后续接入开启番茄钟专注
    override func performPrimaryAction() {
        let config = FocusState.shared.pomodoroConfig
        let timer = FocusSystemPomodoroTimer(config: config)
        FocusPresenter.startFocus(with: timer)
    }
}
