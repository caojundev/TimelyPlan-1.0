//
//  GoalPlanListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation
import UIKit

protocol GoalPlanListViewDelegate: TPGroupCollectionViewDelegate {
    
    /// 通知外部数据源移动数据条目
    func goalPlanListView(_ listView: GoalPlanListView,
                          moveItemAt sourceIndexPath: IndexPath,
                          to targetIndexPath: IndexPath)
    
    /// 处理下拉刷新
    func goalPlanListViewHandleRefresh(_ listView: GoalPlanListView)
}

extension GoalPlanListViewDelegate {
    
    func goalPlanListView(_ listView: GoalPlanListView,
                          moveItemAt sourceIndexPath: IndexPath,
                          to targetIndexPath: IndexPath) {
    }
}

class GoalPlanListView: TPGroupCollectionView,
                        GoalPlanListCellDelegate,
                        TPCollectionDragInsertReorderDelegate {
    
    /// 当前列表所有的目标计划
    var goalPlans: [GoalPlan] {
        return adapter.allItems() as? [GoalPlan] ?? []
    }
    
    var isReorderEnabled: Bool {
        get {
            return self.reorder?.isEnabled ?? false
        }
        
        set {
            self.reorder?.isEnabled = newValue
        }
    }
    
    private var reorder: TPCollectionDragInsertReorder?
    
    private let cellStyle = GoalPlanCellStyle()
    
    private let menuProcessor = GoalPlanMenuProcessor()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.preferredItemWidth = GoalConfig.goalPlanListContentMaxWidth
        self.preferredItemHeight = GoalPlanListCell.cellHeight
        self.setupReorder()
        self.addRefreshControl()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 初始化排序管理器
    private func setupReorder() {
        let reorder = TPCollectionDragInsertReorder(collectionView: self.collectionView)
        reorder.indicatorBackColor = Color(0xFFFFFF, 0.1)
        reorder.isEnabled = false
        reorder.delegate = self
        self.reorder = reorder
    }
    
    override func handleRefresh() {
        guard let delegate = self.delegate as? GoalPlanListViewDelegate else {
            return
        }
        
        delegate.goalPlanListViewHandleRefresh(self)
    }
    
    // MARK: - AdapterDelegate
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return GoalPlanListCell.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? GoalPlanListCell else {
            return
        }
        
        let goalPlan = adapter.item(at: indexPath) as? GoalPlan
        cell.delegate = self
        cell.cellStyle = cellStyle
        cell.goalPlan = goalPlan
    }
    
    // MARK: - TPCollectionDragInsertReorderDelegate
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                     canInsertItemTo targetIndexPath: IndexPath,
                                     from sourceIndexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                     inserItemTo targetIndexPath: IndexPath,
                                     from sourceIndexPath: IndexPath,
                                     depth: Int) -> IndexPath? {
        guard let delegate = self.delegate as? GoalPlanListViewDelegate else {
            return sourceIndexPath
        }
        
        delegate.goalPlanListView(self, moveItemAt: sourceIndexPath, to: targetIndexPath)
        adapter.moveItem(at: sourceIndexPath, to: targetIndexPath)
        return targetIndexPath
    }
    
    // MARK: - GoalPlanListCellDelegate
    func goalPlanListCellDidClickMore(_ cell: GoalPlanListCell) {
        guard let goalPlan = cell.goalPlan,
              let indexPath = self.adapter.indexPath(of: goalPlan) else {
            return
        }
        
        let menuController = GoalPlanMenuController(goalPlan: goalPlan)
        
        menuController.didSelectMenuActionType = { [weak self] type in
            self?.menuProcessor.performMenuAction(type, for: goalPlan)
        }
        
        menuController.showMenu(from: cell.moreButton)
    }
}
