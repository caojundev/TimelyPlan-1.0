//
//  WSDashboardManageViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/20.
//

import Foundation

// MARK: - 面板变化
/// 面板列表变化类型
enum WSDashboardManageChange {
    
    /// 新建面板
    case create(WSDashboard)
    
    /// 更新面板
    case update(WSDashboard)
}

/// 面板管理数据视图模型
class WSDashboardManageViewModel: WorkspaceDashboardProcessorDelegate {
    
    /// 面板列表改变
    var onDashboardsChanged: ((WSDashboardManageChange?) -> Void)?
    
    /// 占位视图
    let placeholderProvider = TPLoadableListPlaceholderProvider()
    
    /// 所有面板
    private(set) var dashboards: [WSDashboard]?
    
    /// 工作台当前展示的面板标识，用于标记选中状态
    private(set) var currentDashboardIdentifier: String?
    
    /// 加载状态
    private(set) var state: TPListLoadingState = .initialLoading {
        didSet {
            placeholderProvider.state = state
        }
    }
    
    /// 是否需要重新获取面板
    private var needsRefresh = true
    
    /// 请求管理器，用于丢弃过期请求的结果
    private let requestManager = TPRequestManager()
    
    init(currentDashboardIdentifier: String?) {
        self.currentDashboardIdentifier = currentDashboardIdentifier
        self.placeholderProvider.state = state
        self.placeholderProvider.emptyTitle = resGetString("No Dashboard")
        WorkspaceRepository.addUpdater(self, for: [.dashboard])
    }
    
    deinit {
        WorkspaceRepository.removeUpdater(self)
    }
    
    // MARK: - 加载面板
    func setNeedsRefresh(_ refresh: Bool = true) {
        self.needsRefresh = refresh
    }
    
    /// 加载面板列表
    func loadDashboards(with change: WSDashboardManageChange? = nil, completion: (() -> Void)? = nil) {
        let requestID = requestManager.executeRequest()
        loadDashboardsIfNeeded { [weak self] dashboards in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                completion?()
                return
            }
            
            self.dashboards = dashboards
            self.needsRefresh = false
            self.updateCurrentDashboardIdentifierIfNeeded()
            self.state = .loaded
            self.onDashboardsChanged?(change)
            completion?()
        }
    }
    
    private func loadDashboardsIfNeeded(completion: @escaping ([WSDashboard]?) -> Void) {
        guard needsRefresh else {
            completion(dashboards)
            return
        }
        
        fetchDashboards(completion: completion)
    }
    
    func fetchDashboards(completion: @escaping ([WSDashboard]?) -> Void) {
        WorkspaceRepository.fetchDashboards(completion: completion)
    }
    
    // MARK: - 处理面板
    /// 创建面板
    func createDashboard(with name: String) {
        WorkspaceRepository.createDashboard(name: name)
    }
    
    /// 更新面板名称
    func updateDashboard(_ dashboard: WSDashboard, with name: String) {
        WorkspaceRepository.updateDashboard(dashboard, name: name)
    }
    
    /// 删除面板
    func deleteDashboard(_ dashboard: WSDashboard) {
        WorkspaceRepository.deleteDashboard(dashboard)
    }
    
    /// 排序面板
    func reorderDashboard(fromIndex: Int, toIndex: Int) -> Bool {
        guard let originDashboards = dashboards else {
            return false
        }
        
        var dashboards = originDashboards
        guard dashboards.moveObject(fromIndex: fromIndex, toIndex: toIndex) else {
            return false
        }
        
        self.dashboards = dashboards
        WorkspaceRepository.didEndReorderDashboards(with: dashboards)
        return true
    }
    
    /// 当前面板已被删除时，工作台会回落到首个面板或收件箱，此处同步选中状态
    private func updateCurrentDashboardIdentifierIfNeeded() {
        let dashboards = self.dashboards ?? []
        guard let identifier = currentDashboardIdentifier,
              identifier != WSDashboard.inboxIdentifier,
              !dashboards.contains(where: { $0.identifier == identifier }) else {
            return
        }
        
        currentDashboardIdentifier = dashboards.first?.identifier ?? WSDashboard.inboxIdentifier
    }
    
    // MARK: - WorkspaceDashboardProcessorDelegate
    func didChangeRemoteWorkspaceDashbaord() {
        setNeedsRefresh()
        loadDashboards()
    }
    
    func didCreateWorkspaceDashbaord(_ board: WSDashboard) {
        setNeedsRefresh()
        loadDashboards(with: .create(board))
    }
    
    func didDeleteWorkspaceDashbaord(_ board: WSDashboard) {
        setNeedsRefresh()
        loadDashboards()
    }
    
    func didUpdateWorkspaceDashbaord(_ board: WSDashboard,
                                     with change: WorkspaceDashboardChange) {
        setNeedsRefresh()
        loadDashboards(with: .update(board))
    }
}
