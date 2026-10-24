//
//  WSFocusUserTimerContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation

// MARK: - 内容交互器

/// 用户计时器组件的内容交互器，各尺寸共用。
class WSFocusUserTimerContentInteractor: WSPluginContentInteractor, FocusTimerProcessorDelegate {
    
    /// 最多展示的计时器数目
    private let maximumItemCount: Int
    
    init(plugin: WSPlugin, context: WSPluginContext, maximumItemCount: Int) {
        self.maximumItemCount = maximumItemCount
        super.init(plugin: plugin, context: context)
        
        /// 观察者由数据仓库弱引用持有，无需手动移除
        FocusRepository.addUpdater(self, for: .timer)
    }
    
    // MARK: - FocusTimerProcessorDelegate
    /// 计时器数据发生变化，重新取数并通知内容视图刷新
    func didChangeRemoteFocusTimer(with results: EntityChangeResults<FocusTimer>?) {
        pluginDataDidChange()
    }
    
    func didCreateFocusTimer(_ timer: FocusTimer) {
        pluginDataDidChange()
    }
    
    func didChangeArchivedState(_ isArchived: Bool, for timer: FocusTimer) {
        pluginDataDidChange()
    }
    
    func didDeleteFocusTimer(_ timer: FocusTimer) {
        pluginDataDidChange()
    }
    
    func didUpdateFocusTimer(_ timer: FocusTimer, with editingTimer: FocusEditingTimer) {
        pluginDataDidChange()
    }
    
    func didMoveFocusTimer(_ timer: FocusTimer) {
        pluginDataDidChange()
    }
    
    // MARK: - 取数
    /// 按配置读取用户计时器：未配置时取最近的活动计时器
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let configuration = plugin.configuration(as: WSFocusUserTimerConfiguration.self)
            ?? WSFocusUserTimerConfiguration()
        let timers = selectedTimers(with: configuration)
        completion(WSFocusUserTimersDataItem(timers: timers))
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示示例计时器，不受用户数据与配置影响，条数与真实展示一致
    override func previewDataItem() -> WSPluginDataItem? {
        /// 番茄钟：6 轮 × 50 分钟
        var deepWorkConfig = FocusPomodoroConfig()
        deepWorkConfig.focusDuration = TimeInterval(50 * SECONDS_PER_MINUTE)
        deepWorkConfig.pomosCountPerCycle = 6
        
        /// 番茄钟：4 轮 × 25 分钟
        var pomodoroConfig = FocusPomodoroConfig()
        pomodoroConfig.focusDuration = TimeInterval(25 * SECONDS_PER_MINUTE)
        pomodoroConfig.pomosCountPerCycle = 4
        
        /// 阶梯计时：三个步骤
        let steppedConfig = FocusSteppedConfig(timerSteps: [FocusTimerStep(),
                                                           FocusTimerStep(),
                                                           FocusTimerStep()])
        
        let examples: [(name: String, colorHex: UInt64, timerType: FocusTimerType, subtitle: String)] = [
            (resGetString("Deep Work"), 0x4A4DFF, .pomodoro, deepWorkConfig.info),
            (resGetString("Reading"), 0xFF9F0A, .pomodoro, pomodoroConfig.info),
            (resGetString("Study"), 0x30D158, .countdown, FocusCountdownConfig(duration: TimeInterval(45 * SECONDS_PER_MINUTE)).info),
            (resGetString("Workout"), 0xFF375F, .countdown, FocusCountdownConfig(duration: TimeInterval(15 * SECONDS_PER_MINUTE)).info),
            (resGetString("Meditation"), 0xAF52DE, .countdown, FocusCountdownConfig(duration: TimeInterval(10 * SECONDS_PER_MINUTE)).info),
            (resGetString("Coffee Break"), 0x64D2FF, .stepped, steppedConfig.info),
            (resGetString("Warm Up"), 0xFFA14E, .stepped, steppedConfig.info),
            (resGetString("Free Focus"), 0x09AFFF, .stopwatch, resGetString("Counting from zero"))
        ]
        
        let items = examples.prefix(maximumItemCount).map { example in
            return WSFocusUserTimerDataItem(timerIdentifier: "preview.\(example.timerType.title).\(example.name)",
                                            title: example.name,
                                            subtitle: example.subtitle,
                                            color: Color(example.colorHex),
                                            timerType: example.timerType)
        }
        
        return WSFocusUserTimersDataItem(items: items)
    }
    
    // MARK: - 主操作
    /// 点击开始按钮：开启指定的用户计时器
    func startFocus(with timerIdentifier: String) {
        guard let timers = FocusRepository.getActiveTimers(),
              let timer = timers.first(where: { $0.identifier == timerIdentifier }) else {
            return
        }
        
        FocusPresenter.startFocus(with: timer)
    }
    
    // MARK: - 数据
    /// 按配置挑选待展示的计时器
    private func selectedTimers(with configuration: WSFocusUserTimerConfiguration) -> [FocusTimer] {
        let activeTimers = FocusRepository.getActiveTimers() ?? []
        
        /// 未配置时按顺序取最近的活动计时器
        guard !configuration.timerIdentifiers.isEmpty else {
            return Array(activeTimers.prefix(maximumItemCount))
        }
        
        let timersByIdentifier = Dictionary(activeTimers.map { ($0.identifier, $0) },
                                            uniquingKeysWith: { first, _ in first })
        let timers = configuration.timerIdentifiers.compactMap { timersByIdentifier[$0] }
        return Array(timers.prefix(maximumItemCount))
    }
}
