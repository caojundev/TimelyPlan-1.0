//
//  WSPluginContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation

// MARK: - 数据条目

/// 工作台组件展示的数据。
///
/// 各组件把自身需要渲染的数据模型声明为遵循该协议；内容视图只按协议接收数据，
protocol WSPluginDataItem {
    
}

class WSPluginContentInteractor: NSObject, TPMidnightUpdatable {
    
    /// 当前数据条目
    private(set) var dataItem: WSPluginDataItem?
    
    /// 数据条目变化回调。单元格把它绑定到内容视图的 `update(with:)`。
    var dataItemDidChange: ((WSPluginDataItem?) -> Void)?
    
    let plugin: WSPlugin
    
    /// 数据是否已过期，需要重新获取
    private var needsReload = true
    
    /// 请求管理，用于丢弃过期请求的结果
    private let requestManager = TPRequestManager()
    
    init(plugin: WSPlugin) {
        self.plugin = plugin
        super.init()
    }
    
    // MARK: - 监听
    func startMidnightObserving() {
        TPMidnightScheduler.shared.addUpdater(self)
    }
    
    func stopMidnightObserving() {
        TPMidnightScheduler.shared.addUpdater(self)
    }
    
    // MARK: - 加载
    /// 按需加载数据。数据仍然有效时直接回调已有数据，避免重复取数。
    func loadDataIfNeeded() {
        guard needsReload else {
            dataItemDidChange?(dataItem)
            return
        }
        
        loadData()
    }
    
    /// 重新加载数据
    func loadData() {
        let requestID = requestManager.executeRequest()
        fetchDataItem { [weak self] dataItem in
            self?.handleLoadedDataItem(dataItem, requestID: requestID)
        }
    }
    
    /// 标记数据已过期并立即重新加载。外部数据变化时调用。
    func setNeedsReload() {
        needsReload = true
        loadData()
    }
    
    // MARK: - 子类实现
    /// 异步获取数据条目。
    ///
    /// 子类只需要实现该方法从数据仓库取数；取数完成后的赋值、渲染与刷新时机
    /// 均由基类统一处理，且在任意线程完成取数都会被安全地回到主线程。
    func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        completion(nil)
    }
    
    // MARK: - 数据回调
    private func handleLoadedDataItem(_ dataItem: WSPluginDataItem?, requestID: UUID) {
        dispatchToMain { [weak self] in
            /// 等待期间又发起了新的请求，丢弃当前结果
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                return
            }
            
            self.needsReload = false
            self.dataItem = dataItem
            self.dataItemDidChange?(dataItem)
        }
    }
    
    private func dispatchToMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
    
    // MARK: - WSPluginDataChangeObserver
    func pluginDataDidChange() {
        dispatchToMain { [weak self] in
            self?.setNeedsReload()
        }
    }
    
    // MARK: - TPMidnightUpdatable
    func updateAtMidnight() {
        dispatchToMain { [weak self] in
            self?.setNeedsReload()
        }
    }
}
