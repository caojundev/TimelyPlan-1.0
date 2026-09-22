//
//  CountdownEventInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/22.
//

import Foundation

class CountdownEventInteractor: CountdownEventProcessorDelegate {
    
    /// 事项内容改变回调（参数为变更描述，可能为 nil 表示未知变更）
    var onEventChange: ((CountdownEventChange?) -> Void)?
    
    /// 事项被删除回调
    var onEventDeleted: (() -> Void)?
    
    /// 倒数日事项（始终为最新内容）
    private(set) var event: CountdownEvent
    
    /// 菜单操作处理器（编辑 / 归档 / 取消归档 / 删除，与列表页一致）
    private let menuProcessor = CountdownEventMenuProcessor()
    
    init(event: CountdownEvent) {
        self.event = event
        CountdownRepository.addUpdater(self)
    }
    
    deinit {
        CountdownRepository.removeUpdater(self)
    }
    
    // MARK: - 事项操作
    
    /// 执行菜单操作
    func performMenuAction(_ type: CountdownEventMenuType) {
        menuProcessor.performMenuAction(type, for: event)
    }
    
    /// 归档事项
    func archiveEvent() {
        CountdownRepository.archiveEvent(event)
    }
    
    /// 取消归档事项
    func unarchiveEvent() {
        CountdownRepository.unarchiveEvent(event)
    }
    
    /// 删除事项
    func deleteEvent() {
        CountdownRepository.deleteEvent(event)
    }
    
    // MARK: - 刷新
    
    /// 重新获取最新事项；事项已不存在时触发删除回调
    private func refreshEvent(_ change: CountdownEventChange?) {
        if let latestEvent = CountdownRepository.getEvent(withIdentifier: event.identifier) {
            event = latestEvent
            dispatchMain { [weak self] in
                self?.onEventChange?(change)
            }
        } else {
            notifyDeleted()
        }
    }
    
    /// 触发删除回调（保证在主线程）
    private func notifyDeleted() {
        dispatchMain { [weak self] in
            self?.onEventDeleted?()
        }
    }
    
    /// 将闭包派发到主线程执行
    private func dispatchMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
}

// MARK: - CountdownEventProcessorDelegate
extension CountdownEventInteractor {
    
    func didChangeRemoteCountdownEvent(with results: EntityChangeResults<CountdownEvent>?) {
        refreshEvent(nil)
    }
    
    func didUpdateCountdownEvent(_ event: CountdownEvent, with change: CountdownEventChange) {
        guard event.identifier == self.event.identifier else {
            return
        }
        
        refreshEvent(change)
    }
    
    func didArchiveCountdownEvent(_ event: CountdownEvent) {
        guard event.identifier == self.event.identifier else {
            return
        }
        
        refreshEvent(nil)
    }
    
    func didUnarchiveCountdownEvent(_ event: CountdownEvent) {
        guard event.identifier == self.event.identifier else {
            return
        }
        
        refreshEvent(nil)
    }
    
    func didDeleteCountdownEvent(_ event: CountdownEvent) {
        guard event.identifier == self.event.identifier else {
            return
        }
        
        notifyDeleted()
    }
}
