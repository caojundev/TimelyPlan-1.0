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
    ///   - completion: 完成回调，参数为可选的习惯任务分组数组
    func habitPeriodItemListView(_ listView: HabitPeriodItemListView, fetchTaskGroups completion: @escaping ([HabitTaskGroup]?) -> Void)
}

class HabitPeriodItemListView: HabitTaskListView {
    
    // MARK: - Properties
    private var groups: [HabitTaskGroup]?
    
    private let requestManager = TPRequestManager()
    
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
    
    func asyncReloadData(animateStyle: SlideStyle) {
        self.groups = nil /// 分组置为空
        changeCollectionView(with: animateStyle)
        asyncReloadData()
    }
    
    /// 异步重新加载数据
    func asyncReloadData() {
        asyncLoadGroups { isSuccess in
            if isSuccess {
                self.reloadData()
            }
        }
    }
    
    /// 异步执行更新
    /// - Parameter completion: 完成回调，参数为是否成功
    func asyncPerformUpdate(completion: ((Bool) -> Void)? = nil) {
        asyncLoadGroups { [weak self] isSuccess in
            if isSuccess {
                self?.performUpdate()
            }
            
            completion?(isSuccess)
        }
    }
    
    // MARK: - Data Loading Methods
    /// 异步加载任务分组
    /// - Parameter completion: 完成回调，参数为是否成功
    private func asyncLoadGroups(completion: @escaping (Bool) -> Void) {
        let requestID = requestManager.executeRequest()
        guard let delegate = delegate as? HabitPeriodItemListViewDelegate else {
            groups = nil
            completion(true)
            return
        }
            
        delegate.habitPeriodItemListView(self) { [weak self] groups in
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
