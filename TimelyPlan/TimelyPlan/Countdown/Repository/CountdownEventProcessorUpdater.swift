//
//  CountdownEventProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation

// MARK: - 倒数日事项处理器代理

protocol CountdownEventProcessorDelegate: AnyObject {
    
    /// 远程倒数日事项发生变更
    func didChangeRemoteCountdownEvent(with results: EntityChangeResults<CountdownEvent>?)
    
    /// 创建新倒数日事项
    func didCreateCountdownEvent(_ event: CountdownEvent)
    
    /// 更新倒数日事项
    func didUpdateCountdownEvent(_ event: CountdownEvent)
    
    /// 删除倒数日事项
    func didDeleteCountdownEvent(_ event: CountdownEvent)
    
    /// 归档倒数日事项
    func didArchiveCountdownEvent(_ event: CountdownEvent)
    
    /// 取消归档倒数日事项
    func didUnarchiveCountdownEvent(_ event: CountdownEvent)
    
    /// 通知倒数日事项的顺序发生改变
    func didReorderCountdownEvent(in events: [CountdownEvent],
                                  fromIndex: Int,
                                  toIndex: Int)
}

extension CountdownEventProcessorDelegate {
    
    func didChangeRemoteCountdownEvent(with results: EntityChangeResults<CountdownEvent>?) {}
    
    func didCreateCountdownEvent(_ event: CountdownEvent) {}
    
    func didUpdateCountdownEvent(_ event: CountdownEvent) {}
    
    func didDeleteCountdownEvent(_ event: CountdownEvent) {}
    
    func didArchiveCountdownEvent(_ event: CountdownEvent) {}
    
    func didUnarchiveCountdownEvent(_ event: CountdownEvent) {}
    
    func didReorderCountdownEvent(in events: [CountdownEvent],
                                  fromIndex: Int,
                                  toIndex: Int) {}
}

class CountdownEventProcessorUpdater: NSObject,
                                     CountdownEventProcessorDelegate {
    
    func didChangeRemoteCountdownEvent(with results: EntityChangeResults<CountdownEvent>?) {
        notifyDelegates { (delegate: CountdownEventProcessorDelegate) in
            delegate.didChangeRemoteCountdownEvent(with: results)
        }
    }
    
    func didCreateCountdownEvent(_ event: CountdownEvent) {
        notifyDelegates { (delegate: CountdownEventProcessorDelegate) in
            delegate.didCreateCountdownEvent(event)
        }
    }
    
    func didUpdateCountdownEvent(_ event: CountdownEvent) {
        notifyDelegates { (delegate: CountdownEventProcessorDelegate) in
            delegate.didUpdateCountdownEvent(event)
        }
    }
    
    func didDeleteCountdownEvent(_ event: CountdownEvent) {
        notifyDelegates { (delegate: CountdownEventProcessorDelegate) in
            delegate.didDeleteCountdownEvent(event)
        }
    }
    
    func didArchiveCountdownEvent(_ event: CountdownEvent) {
        notifyDelegates { (delegate: CountdownEventProcessorDelegate) in
            delegate.didArchiveCountdownEvent(event)
        }
    }
    
    func didUnarchiveCountdownEvent(_ event: CountdownEvent) {
        notifyDelegates { (delegate: CountdownEventProcessorDelegate) in
            delegate.didUnarchiveCountdownEvent(event)
        }
    }
    
    func didReorderCountdownEvent(in events: [CountdownEvent],
                                  fromIndex: Int,
                                  toIndex: Int) {
        notifyDelegates { (delegate: CountdownEventProcessorDelegate) in
            delegate.didReorderCountdownEvent(in: events,
                                              fromIndex: fromIndex,
                                              toIndex: toIndex)
        }
    }
}
