//
//  CalendarEventProcessor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/23.
//

import Foundation
import EventKit

class CalendarEventProcessor {
    
    private let repository = CalendarRepository()
    
    /// 更新事项日期
    func updateEvent(_ event: CalendarEvent, with dateRange: DateInterval, completion: @escaping ((Bool) -> Void)) {
        switch event.source {
        case .local:
            updateLocalEvent(event, with: dateRange, completion: completion)
        case .system:
            updateSystemEvent(event, with: dateRange, completion: completion)
        }
    }
    
    private func updateLocalEvent(_ event: CalendarEvent, with dateRange: DateInterval, completion: @escaping ((Bool) -> Void)) {
        repository.updateLocalEvent(event, with: dateRange)
        completion(true)
    }
    
    private func updateSystemEvent(_ event: CalendarEvent, with dateRange: DateInterval, completion: @escaping ((Bool) -> Void)) {
        guard let ekEvent = event.sourceItem as? EKEvent else {
            completion(false)
            return
        }
        
        CalendarSystemManager.shared.updateEventWithConfirmation(ekEvent, with: dateRange) { result in
            switch result {
            case .success:
                debugPrint("事项更新成功")
                completion(true)
            case .failure(let error):
                debugPrint("事项更新失败: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    /// 点击事项
    func clickEvent(_ event: CalendarEvent) {
        switch event.source {
        case .local:
            clickLocalEvent(event)
        case .system:
            previewSystemEvent(event)
        }
    }
    
    /// 编辑本地事项
    private func clickLocalEvent(_ event: CalendarEvent) {
        guard let task = event.sourceItem as? TodoTask else {
            return
        }
        
        if task.isDetached {
            CalendarPresenter.previewEvent(event)
        } else {
            CalendarPresenter.editLocalEvent(event)
        }
    }
    
    /// 预览系统事项
    private func previewSystemEvent(_ event: CalendarEvent) {
        guard let _ = event.sourceItem as? EKEvent else {
            return
        }
        
        CalendarPresenter.previewEvent(event)
    }
    
}
