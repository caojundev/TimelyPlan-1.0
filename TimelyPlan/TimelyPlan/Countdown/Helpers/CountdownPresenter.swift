//
//  CountdownPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation
import UIKit

class CountdownPresenter {
    
    /// 创建新倒数日事项
    /// - Parameters:
    ///   - type: 事项类型，决定默认表情
    ///   - editingEvent: 预填的编辑信息，nil 时按类型生成默认值
    static func createNewEvent(type: CountdownEventType = .countdown,
                               editingEvent: CountdownEditingEvent? = nil) {
        let editingEvent = editingEvent ?? defaultEditingEvent(for: type)
        let vc = CountdownEventEditViewController(event: editingEvent,
                                                  editType: .create)
        vc.didEndEditing = { editingEvent in
            CountdownRepository.createEvent(with: editingEvent)
        }
        
        vc.showAsNavigationRoot()
    }
    
    /// 编辑倒数日事项
    static func editEvent(_ event: CountdownEvent) {
        let vc = CountdownEventEditViewController(event: event.editingEvent,
                                                  editType: .modify)
        vc.didEndEditing = { editingEvent in
            CountdownRepository.updateEvent(event, with: editingEvent)
        }
        
        vc.showAsNavigationRoot()
    }
    
    // MARK: - 默认值
    /// 按事项类型生成默认编辑信息（默认表情取类型表情）
    private static func defaultEditingEvent(for type: CountdownEventType) -> CountdownEditingEvent {
        var editingEvent = CountdownEditingEvent(type: type)
        editingEvent.emoji = type.emoji
        return editingEvent
    }
}
