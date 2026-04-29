//
//  FocusState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/24.
//

class FocusState {
    
    enum SettingKey: String, SettingKeyRepresentable {
        case floatingTimerPosition
        case mainMenuType /// 专注主菜单类型
        case timerType
        case pomodoroPhase
        case pomodoroConfig
        case countdownConfig
        case recordListOrder /// 记录列表排列顺序
        case recordListMode  /// 记录列表模式
        
        static func keyPrefix() -> String? {
            return "FocusState"
        }
    }

    @LocalStored(key: SettingKey.mainMenuType.name, defaultValue: .focus)
    var mainMenuType: FocusMainMenuType

    @LocalStored(key: SettingKey.floatingTimerPosition.name, defaultValue: FocusFloatingTimerPosition())
    var floatingTimerPosition: FocusFloatingTimerPosition

    @LocalStored(key: SettingKey.timerType.name, defaultValue: .pomodoro)
    var timerType: FocusTimerType
    
    @LocalStored(key: SettingKey.pomodoroConfig.name, defaultValue: FocusPomodoroConfig())
    var pomodoroConfig: FocusPomodoroConfig

    @LocalStored(key: SettingKey.pomodoroPhase.name, defaultValue: .focus)
    var pomodoroPhase: FocusPomodoroPhase

    @LocalStored(key: SettingKey.countdownConfig.name, defaultValue: FocusCountdownConfig())
    var countdownConfig: FocusCountdownConfig
    
    @LocalStored(key: SettingKey.recordListOrder.name, defaultValue: .ascending)
    var recordListOrder: FocusRecordSortOrder
    
    @LocalStored(key: SettingKey.recordListMode.name, defaultValue: .detail)
    var recordListMode: FocusRecordListMode
    
    static let shared = FocusState()
    
    private init() {}
    
    // MARK: - Observer
    func addObserver(_ observer: SettingAgentObserver, forKey key: SettingKey) {
        SettingAgent.shared.addObserver(observer, forKey: key.name)
    }
    
    func addObserver(_ observer: SettingAgentObserver, forKeys keys: [SettingKey]) {
        let names = keys.map { $0.name }
        SettingAgent.shared.addObserver(observer, forKeys: names)
    }
}
