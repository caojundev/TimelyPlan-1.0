//
//  FocusStateStore.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/24.
//

class FocusStateStore {
    
    enum SettingKey: String, SettingKeyRepresentable {
        case timerType
        case floatingTimerPosition
        case defaultPomodoroConfig
        case defaultCountdownConfig
        
        static func keyPrefix() -> String? {
            return "FocusState"
        }
    }

    @LocalStored(key: SettingKey.floatingTimerPosition.name, defaultValue: FocusFloatingTimerPosition())
    var floatingTimerPosition: FocusFloatingTimerPosition

    @LocalStored(key: SettingKey.defaultPomodoroConfig.name, defaultValue: FocusPomodoroConfig())
    var pomodoroConfig: FocusPomodoroConfig

    @LocalStored(key: SettingKey.defaultCountdownConfig.name, defaultValue: FocusCountdownConfig())
    var countdownConfig: FocusCountdownConfig

    static let shared = FocusStateStore()
    
    private init() {}
}
