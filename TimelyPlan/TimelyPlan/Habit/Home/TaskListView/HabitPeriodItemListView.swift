//
//  HabitPeriodItemListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/7.
//

import Foundation
import UIKit

class HabitGroupExpansionState: ExpansionStateProviding {
    
    private var collapsedStates: [String: Bool]
    
    init() {
//        self.collapsedStates = TodoState.shared.collapsedListStates ?? [:]
        self.collapsedStates = [:]
    }
    
    func isExpanded(_ item: Any) -> Bool {
        let group = item as! HabitTaskGroup
        let isCollapsed = collapsedStates[group.identifier] ?? false
        return !isCollapsed
    }
    
    func setExpended(_ isExpended: Bool, for item: Any) {
        let group = item as! HabitTaskGroup
        if isExpended {
            collapsedStates[group.identifier] = nil
        } else {
            collapsedStates[group.identifier] = true
        }
    }
}


class HabitPeriodItemListView: TPGroupCollectionView,
                               HabitTaskListGroupHeaderViewDelegate {
    
    var expansionState = HabitGroupExpansionState()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.shouldShowPlaceholder = { [weak self] in
            return self?.showPlaceholder() ?? false
        }
        
        self.addRefreshControl()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 是否显示占位视图
    private func showPlaceholder() -> Bool {
        guard let groups = self.groups else {
            return true
        }
        
        return groups.count == 0
    }
    
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
    
    override func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        guard let group = sectionObject as? HabitTaskGroup,
              expansionState.isExpanded(group) else {
            return nil
        }
        
        return group.tasks
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        super.adapter(adapter, didDequeHeader: headerView, inSection: section)
        if let headerView = headerView as? HabitTaskListGroupHeaderView {
            headerView.updateExpanded(animated: true)
        }
    }
    
    // MARK: - HabitTaskListGroupHeaderViewDelegate
    func isExpandedGroupHeaderView(_ headerView: HabitTaskListGroupHeaderView) -> Bool {
        guard let group = headerView.group else {
            return true
        }
        
        return expansionState.isExpanded(group)
    }
    
    func groupHeaderView(_ headerView: HabitTaskListGroupHeaderView, didToggleExpand isExpanded: Bool) {
        guard let group = headerView.group else {
            return
        }
        
        expansionState.setExpended(isExpanded, for: group)
        performUpdate()
    }
    
    
}
