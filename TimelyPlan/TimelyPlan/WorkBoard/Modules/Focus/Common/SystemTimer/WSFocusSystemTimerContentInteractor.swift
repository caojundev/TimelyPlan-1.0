//
//  WSFocusSystemTimerContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation

// MARK: - 内容交互器

/// 专注·默认计时器的内容交互器。小尺寸与中尺寸共用。
class WSFocusSystemTimerContentInteractor: WSPluginContentInteractor, SettingAgentObserver {
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        
        /// 观察者由 `SettingAgent` 弱引用持有，无需手动移除
        FocusState.shared.addObserver(self, forKey: .pomodoroConfig)
        FocusState.shared.addObserver(self, forKey: .countdownConfig)
    }
    
    // MARK: - SettingAgentObserver
    /// 默认番茄钟 / 倒计时配置变化：重新取数并通知内容视图刷新
    func settingAgentDidChangeValue(for keyName: String) {
        let keys = [FocusState.SettingKey.pomodoroConfig.name,
                    FocusState.SettingKey.countdownConfig.name]
        guard keys.contains(keyName) else {
            return
        }
        
        pluginDataDidChange()
    }
    
    // MARK: - 取数
    /// 组装三个默认系统计时器，计时状态待后续实现
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        completion(makeDataItem(pomodoroConfig: FocusState.shared.pomodoroConfig,
                                countdownConfig: FocusState.shared.countdownConfig))
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：使用默认配置
    override func previewDataItem() -> WSPluginDataItem? {
        return makeDataItem(pomodoroConfig: FocusPomodoroConfig(),
                            countdownConfig: FocusCountdownConfig())
    }
    
    // MARK: - 主操作
    /// 点击开始按钮：开启对应类型的默认计时器
    func startFocus(with timerType: FocusTimerType) {
        guard let timer = makeTimer(for: timerType) else {
            return
        }
        
        FocusPresenter.startFocus(with: timer)
    }
    
    // MARK: - 数据
    private func makeDataItem(pomodoroConfig: FocusPomodoroConfig,
                              countdownConfig: FocusCountdownConfig) -> WSFocusSystemTimerDataItem {
        let pomodoroTimer = FocusSystemPomodoroTimer(config: pomodoroConfig)
        let countdownTimer = FocusSystemCountdownTimer(config: countdownConfig)
        let stopwatchTimer = FocusSystemStopwatchTimer()
        
        return WSFocusSystemTimerDataItem(pomodoroTimer: pomodoroTimer,
                                          countdownTimer: countdownTimer,
                                          stopwatchTimer: stopwatchTimer)
    }
    
    /// 创建指定类型的默认计时器
    private func makeTimer(for timerType: FocusTimerType) -> FocusSystemTimer? {
        switch timerType {
        case .pomodoro:
            return FocusSystemPomodoroTimer(config: FocusState.shared.pomodoroConfig)
        case .countdown:
            return FocusSystemCountdownTimer(config: FocusState.shared.countdownConfig)
        case .stopwatch:
            return FocusSystemStopwatchTimer()
        case .stepped:
            return nil
        }
    }
}
