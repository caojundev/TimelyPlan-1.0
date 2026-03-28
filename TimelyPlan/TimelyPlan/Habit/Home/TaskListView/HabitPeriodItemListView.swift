//
//  HabitPeriodItemListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/7.
//

import Foundation
import UIKit

protocol HabitPeriodItemListViewDelegate: HabitTaskListViewDelegate {
    /// 异步获取习惯任务分组数据
    /// - Parameters:
    ///   - listView: 发起请求的习惯周期任务列表视图
    ///   - forceRefresh: 是否强制刷新
    ///   - completion: 完成回调，参数为可选的习惯任务分组数组
    func habitPeriodItemListView(_ listView: HabitPeriodItemListView,
                                 forceRefresh: Bool,
                                 fetchTaskGroups completion: @escaping ([HabitTaskGroup]?) -> Void)
}

class HabitPeriodItemListView: HabitTaskListView {
    
    private var groups: [HabitTaskGroup]?
    
    private let requestManager = TPRequestManager()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupRefreshControl()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 下拉刷新
    override func handleRefresh() {
        self.asyncReloadData()
    }
    
    // MARK: - Override Methods
    override func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return groups
    }
    
    // MARK: - Public Methods
    /// 聚焦显示任务
    /// - Parameter task: 要显示的习惯任务
    func revealTask(_ task: HabitTask, autoScroll: Bool = true) {
        let indexPath = adapter.findIndexPath { item in
            guard let item = item as? HabitPeriodItem else {
                return false
            }
            
            return task.identifier == item.habitTask.identifier
        }
        
        if let indexPath = indexPath {
            let periodItem = adapter.item(at: indexPath)
            revealItem(periodItem, autoScroll: autoScroll)
        }
    }
    
    func asyncReloadData(forceRefresh: Bool = true, animateStyle: SlideStyle = .none) {
        self.groups = nil /// 分组置为空
        changeCollectionView(with: animateStyle)
        asyncReloadData(forceRefresh: forceRefresh)
    }
    
    /// 异步重新加载数据
    func asyncReloadData(forceRefresh: Bool = true) {
        asyncLoadGroups(forceRefresh: forceRefresh) { isSuccess in
            if isSuccess {
                self.reloadData()
            }
        }
    }
    
    /// 异步执行更新
    /// - Parameter completion: 完成回调，参数为是否成功
    func asyncPerformUpdate(forceRefresh: Bool = true, completion: ((Bool) -> Void)? = nil) {
        asyncLoadGroups(forceRefresh: forceRefresh) { [weak self] isSuccess in
            if isSuccess {
                self?.performUpdate()
            }
            
            completion?(isSuccess)
        }
    }
    
    // MARK: - Data Loading Methods
    /// 异步加载任务分组
    /// - Parameter completion: 完成回调，参数为是否成功
    private func asyncLoadGroups(forceRefresh: Bool = true, completion: @escaping (Bool) -> Void) {
        let requestID = requestManager.executeRequest()
        guard let delegate = delegate as? HabitPeriodItemListViewDelegate else {
            self.refreshControl.endRefreshing()
            completion(true)
            return
        }
            
        delegate.habitPeriodItemListView(self, forceRefresh: forceRefresh) { [weak self] groups in
            self?.refreshControl.endRefreshing()
            guard let self = self else {
                completion(false)
                return
            }
                
            guard self.requestManager.shouldProceed(with: requestID) else {
                completion(false)
                return
            }
                
            self.groups = groups
            completion(true)
        }
    }
}
