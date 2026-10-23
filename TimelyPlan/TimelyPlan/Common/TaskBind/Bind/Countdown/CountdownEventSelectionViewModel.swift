//
//  CountdownEventSelectionViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/23.
//

import Foundation

/// 倒数日事项选择列表的 ViewModel。
///
/// 任务绑定与插件配置共用：负责加载活动倒数日事项、监听数据变更，
/// 并在列表变化时通过 `didChangeEvents` 通知视图刷新。
class CountdownEventSelectionViewModel {
    
    /// 事项列表变化回调
    var didChangeEvents: (([CountdownEvent]) -> Void)?
    
    /// 当前展示的倒数日事项
    private(set) var events: [CountdownEvent] = []
    
    /// 请求管理，避免旧请求覆盖新结果
    private let requestManager = TPRequestManager()
    
    // MARK: - 监听
    /// 开始监听事项变更并加载数据
    func startObserving() {
        CountdownRepository.addUpdater(self, for: [.event])
        loadEvents()
    }
    
    /// 停止监听
    func stopObserving() {
        CountdownRepository.removeUpdater(self)
    }
    
    // MARK: - 数据
    /// 加载活动倒数日事项
    func loadEvents() {
        let requestID = requestManager.executeRequest()
        CountdownRepository.fetchActiveEvents { [weak self] events in
            guard let self = self,
                  self.requestManager.shouldProceed(with: requestID) else {
                return
            }
            
            DispatchQueue.main.async {
                self.events = events ?? []
                self.didChangeEvents?(self.events)
            }
        }
    }
}

// MARK: - CountdownEventProcessorDelegate

extension CountdownEventSelectionViewModel: CountdownEventProcessorDelegate {
    
    func didChangeRemoteCountdownEvent(with results: EntityChangeResults<CountdownEvent>?) {
        loadEvents()
    }
    
    func didCreateCountdownEvent(_ event: CountdownEvent) {
        loadEvents()
    }
    
    func didUpdateCountdownEvent(_ event: CountdownEvent, with change: CountdownEventChange) {
        loadEvents()
    }
    
    func didDeleteCountdownEvent(_ event: CountdownEvent) {
        loadEvents()
    }
    
    func didArchiveCountdownEvent(_ event: CountdownEvent) {
        loadEvents()
    }
    
    func didUnarchiveCountdownEvent(_ event: CountdownEvent) {
        loadEvents()
    }
}
