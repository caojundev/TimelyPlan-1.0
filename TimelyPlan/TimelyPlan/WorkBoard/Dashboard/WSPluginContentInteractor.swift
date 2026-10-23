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
    
    /// 展示上下文。画廊下只提供预览数据，不访问数据仓库
    let context: WSPluginContext
    
    /// 数据是否已过期，需要重新获取
    private var needsReload = true
    
    /// 请求管理，用于丢弃过期请求的结果
    private let requestManager = TPRequestManager()
    
    init(plugin: WSPlugin, context: WSPluginContext) {
        self.plugin = plugin
        self.context = context
        super.init()
        /// 跨天后剩余时间需要重新换算，所有组件统一监听零点更新
        startMidnightObserving()
    }
    
    deinit {
        stopMidnightObserving()
    }
    
    // MARK: - 监听
    func startMidnightObserving() {
        TPMidnightScheduler.shared.addUpdater(self)
    }
    
    func stopMidnightObserving() {
        TPMidnightScheduler.shared.removeUpdater(self)
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
        
        /// 画廊只渲染固定的预览数据，不读取用户数据
        guard context == .dashboard else {
            handleLoadedDataItem(previewDataItem(), requestID: requestID)
            return
        }
        
        fetchDataItem { [weak self] dataItem in
            self?.handleLoadedDataItem(dataItem, requestID: requestID)
        }
    }
    
    /// 标记数据已过期并立即重新加载。外部数据变化时调用。
    func setNeedsReload() {
        needsReload = true
        loadData()
    }
    
    // MARK: - 交互
    /// 执行组件的主操作（点击组件主体时触发）。
    ///
    /// 默认不响应，由各模块按需覆写，以便直接使用交互器持有的插件配置与取数结果。
    func performPrimaryAction() {
        
    }
    
    /// 执行内容内某个条目的操作（点击条目等）。
    ///
    /// 内容视图通过注入的 `interactor` 直接调用这里，单元格无需关心具体是点击还是其它操作；
    /// 默认不响应，由各模块按需覆写，以便按条目数据打开对应详情。
    func performAction(with dataItem: WSPluginDataItem) {
        
    }
    
    /// 执行空白行的操作（点击没有对应条目的行时触发）。
    ///
    /// 内容视图只负责告知「点击了空白行」，是否响应以及如何响应完全由各模块决定；
    /// 默认不响应，由各模块按需覆写，例如打开列表页、进入新增流程等。
    func performEmptyRowAction() {
        
    }
    
    // MARK: - 子类实现
    /// 异步获取数据条目。
    ///
    /// 子类只需要实现该方法从数据仓库取数；取数完成后的赋值、渲染与刷新时机
    /// 均由基类统一处理，且在任意线程完成取数都会被安全地回到主线程。
    func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        completion(nil)
    }
    
    /// 画廊预览数据。默认 nil，此时画廊展示空白占位视图。
    ///
    /// 由各模块提供一份固定的、具有代表性的内容，避免画廊因用户尚未配置而显示空白。
    func previewDataItem() -> WSPluginDataItem? {
        return nil
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
        /// 画廊使用固定预览数据，无需响应数据变化
        guard context == .dashboard else {
            return
        }
        
        dispatchToMain { [weak self] in
            self?.setNeedsReload()
        }
    }
    
    // MARK: - TPMidnightUpdatable
    func updateAtMidnight() {
        /// 画廊使用固定预览数据，无需跨天刷新
        guard context == .dashboard else {
            return
        }
        
        dispatchToMain { [weak self] in
            self?.setNeedsReload()
        }
    }
}
