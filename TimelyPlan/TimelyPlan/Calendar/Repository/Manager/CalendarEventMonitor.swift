//
//  CalendarEventMonitor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/12.
//

import Foundation
import EventKit

class CalendarEventMonitor {
    
    private var isObserving = false
    
    // 变化回调
    var onEventsChanged: (() -> Void)?
    
    deinit {
        stopObserving()
    }
    
    init() {
        startObserving()
    }
    
    // MARK: - 开始监听
    func startObserving() {
        guard !isObserving else { return }
        
        // 监听日历数据库变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEventStoreChanged(_:)),
            name: .EKEventStoreChanged,
            object: nil
        )
        
        isObserving = true
    }
    
    // MARK: - 停止监听
    func stopObserving() {
        guard isObserving else { return }
        
        NotificationCenter.default.removeObserver(
            self,
            name: .EKEventStoreChanged,
            object: nil
        )
        
        isObserving = false
    }
    
    // MARK: - 处理变化
    @objc private func handleEventStoreChanged(_ notification: Notification) {
        // 在主线程回调
        DispatchQueue.main.async { [weak self] in
            self?.onEventsChanged?()
        }
    }
}
