//
//  CountdownNotifiableEventProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/22.
//

import Foundation

class CountdownNotifiableEventProvider: LocalNotifiableTaskProvider {
    
    /// 通知任务改变代理
    weak var delegate: LocalNotifiableTaskChangeDelegate?

    /// 任务数组
    private var results: [LocalNotifiable] = []
    
    /// 是否需要刷新任务
    private var needsRefresh = true

    private let requestManager = TPRequestManager()
    
    init() {
        /// 添加倒数日事项处理监听
        CountdownRepository.addUpdater(self, for: .event)
    }
    
    func setNeedsRefresh() {
        needsRefresh = true
    }
    
    func fetchNotifiableTasks(completion: @escaping ([LocalNotifiable]) -> Void) {
        guard needsRefresh else {
            completion(results)
            return
        }
        
        /// 重新获取
        let requestID = requestManager.executeRequest()
        CountdownRepository.fetchNotifiableEvents { [weak self] events in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                completion([])
                return
            }

            self.needsRefresh = false
            self.results = events ?? []
            completion(self.results)
        }
    }
}

extension CountdownNotifiableEventProvider: CountdownEventProcessorDelegate {
    
    func didChangeRemoteCountdownEvent(with results: EntityChangeResults<CountdownEvent>?) {
        setNeedsRefresh()
        delegate?.localNotifiableTaskDidChange()
    }
    
    func didCreateCountdownEvent(_ event: CountdownEvent) {
        if event.hasReminder {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    func didUpdateCountdownEvent(_ event: CountdownEvent, with change: CountdownEventChange) {
        var shouldRefresh = false
        switch change {
        case .content(let oldValue, let newValue):
            if oldValue.reminder != newValue.reminder {
                /// 提醒被新增、修改或移除
                shouldRefresh = true
            } else if event.hasReminder {
                /// 仍有提醒时，日期、重复规则或名称改变都会影响通知
                shouldRefresh = oldValue.date != newValue.date
                    || oldValue.timePlan != newValue.timePlan
                    || oldValue.name != newValue.name
            }
        default:
            break
        }
        
        if shouldRefresh {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    func didDeleteCountdownEvent(_ event: CountdownEvent) {
        if event.hasReminder {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    func didArchiveCountdownEvent(_ event: CountdownEvent) {
        if event.hasReminder {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    func didUnarchiveCountdownEvent(_ event: CountdownEvent) {
        if event.hasReminder {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
}
