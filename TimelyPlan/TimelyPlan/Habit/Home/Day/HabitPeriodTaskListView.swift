//
//  HabitPeriodTaskListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/7.
//

import Foundation
import UIKit

protocol HabitPeriodTaskListViewDelegate: HabitTaskListViewDelegate {
    /// 异步获取习惯任务分组数据
    /// - Parameters:
    ///   - listView: 发起请求的习惯周期任务列表视图
    ///   - completion: 完成回调，参数为可选的习惯任务分组数组
    func habitPeriodTaskListView(_ listView: HabitPeriodTaskListView, fetchTaskGroups completion: @escaping ([HabitTaskGroup]?) -> Void)
}

class HabitPeriodTaskListView: HabitTaskListView {
    
    // MARK: - Properties
    private var groups: [HabitTaskGroup]?
    
    private let requestManager = TPRequestManager()
    
    // MARK: - Override Methods
    override func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return groups
    }
    
    // MARK: - Public Methods
    func asyncReloadData(animateStyle: SlideStyle) {
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
        guard let delegate = delegate as? HabitPeriodTaskListViewDelegate else {
            groups = nil
            completion(true)
            return
        }
            
        delegate.habitPeriodTaskListView(self) { [weak self] groups in
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
