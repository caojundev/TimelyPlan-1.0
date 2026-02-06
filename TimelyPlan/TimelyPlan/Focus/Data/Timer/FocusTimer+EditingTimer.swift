//
//  FocusTimer+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/25.
//

import Foundation
import UIKit

extension FocusTimer {
    
    /// 根据编辑任务创建新任务
    static func newTimer(with editingTimer: FocusEditingTimer) -> FocusTimer {
        let timer = FocusTimer.createEntity(in: .defaultContext)
        timer.identifier = UUID().uuidString ///新创建任务设置标识
        timer.creationDate = .now
        timer.update(with: editingTimer)
        return timer
    }
    
    /// 获取编辑任务
    var editingTimer: FocusEditingTimer {
        var timer = FocusEditingTimer()
        timer.name = name
        timer.color = color ?? defaultColor
        timer.config = config?.copy() as? FocusTimerConfig
        return timer
    }
    
    func update(with editingTimer: FocusEditingTimer) {
        self.name = editingTimer.name
        self.colorHex = editingTimer.color.hexString
        self.note = editingTimer.note
        self.config = editingTimer.config?.copy() as? FocusTimerConfig
        self.modificationDate = .now
    }
    
    /// 判断编辑任务内容是否与当前任务相同
    func isSameTimer(as editingTimer: FocusEditingTimer) -> Bool {
        return editingTimer.name == name &&
        editingTimer.color == color &&
        editingTimer.config == config &&
        editingTimer.note == note
    }
}
