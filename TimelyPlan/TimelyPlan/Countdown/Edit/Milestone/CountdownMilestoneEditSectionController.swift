//
//  CountdownMilestoneEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/20.
//

import Foundation
import UIKit

// MARK: - 里程碑编辑区块
/// 参考 `TaskReminderEditSectionController` 实现，用于编辑倒数日提醒的里程碑，
/// 依次展示「已设置的里程碑（按类型与间隔排序）」「预设里程碑」「自定义里程碑」
class CountdownMilestoneEditSectionController: TPTableItemSectionController,
                                               TPMultipleItemSelectionDelegate {
    
    /// 是否可以添加新里程碑
    var canAddMilestone: (() -> Bool)?
    
    /// 点击自定义
    var didClickCustom: (() -> Void)?
    
    /// 里程碑改变
    var milestonesDidChange: (([CountdownMilestone]) -> Void)?
    
    /// 已设置的里程碑数目
    var milestonesCount: Int {
        return selection.selectedCount
    }
    
    /// 已设置的里程碑（按类型与间隔排序）
    var milestones: [CountdownMilestone] {
        return selection.selectedItems.sorted()
    }
    
    /// 里程碑选择管理器
    private var selection: TPMultipleItemSelection<CountdownMilestone>
    
    /// 已设置的里程碑
    lazy var milestonesCellItem: CountdownMilestoneListTableCellItem = {
        let cellItem = CountdownMilestoneListTableCellItem()
        cellItem.height = 60.0
        cellItem.editingEnabled = true
        return cellItem
    }()
    
    /// 预设里程碑
    lazy var presetMilestonesCellItem: CountdownMilestonePresetListTableCellItem = {
        let cellItem = CountdownMilestonePresetListTableCellItem(date: date)
        cellItem.milestones = CountdownMilestone.presets
        return cellItem
    }()
    
    /// 自定义里程碑
    lazy var customCellItem: TPFullSizeButtonTableCellItem = { [weak self] in
        let cellItem = TPFullSizeButtonTableCellItem()
        cellItem.buttonNormalTitleColor = resGetColor(.title)
        cellItem.buttonTitle = resGetString("Custom")
        cellItem.buttonImageName = "plus_24"
        cellItem.buttonImageColor = resGetColor(.title)
        cellItem.updater = {
            let canAddMilestone = self?.canAddMilestone?() ?? false
            self?.customCellItem.isDisabled = !canAddMilestone
        }
        
        cellItem.didClickButton = { _ in
            self?.didClickCustom?()
        }
        
        return cellItem
    }()
    
    /// 头标题
    var headerTitle: String? {
        didSet {
            headerItem.title = headerTitle
        }
    }
    
    let date: CountdownDate
    
    init(milestones: [CountdownMilestone]?, date: CountdownDate) {
        self.selection = TPMultipleItemSelection(items: milestones ?? [])
        self.date = date
        super.init()
        let headerItem = TPDefaultInfoTableHeaderFooterItem()
        headerItem.height = 0.0
        self.headerItem = headerItem
        
        self.selection.delegate = self
        self.milestonesCellItem.selection = self.selection
        self.presetMilestonesCellItem.selection = self.selection
        self.cellItems = [self.milestonesCellItem,
                          self.presetMilestonesCellItem,
                          self.customCellItem]
    }
    
    /// 更新里程碑可选状态
    func updateEnabled() {
        adapter?.reloadCell(forItem: customCellItem, with: .none)
        selection.notifyUpdaters(inserts: nil, deletes: nil)
    }
    
    /// 创建自定义里程碑
    func didCreateMilestone(_ milestone: CountdownMilestone) {
        if !selection.isSelectedItem(milestone) {
            selection.selectItem(milestone)
        } else {
            /// 已经存在该提醒
            let cell = adapter?.cellForItem(milestonesCellItem) as? CountdownMilestoneListTableViewCell
            cell?.listView.scrollToAndCommitFocusAnimation(for: milestone)
        }
        
    }
    
    // MARK: - TPMultipleItemSelectionDelegate
    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, canSelectItem item: T) -> Bool where T : Hashable {
        return canAddMilestone?() ?? false
    }
    
    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, canDeselectItem item: T) -> Bool where T : Hashable {
        return true
    }
    
    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, didSelectItem item: T) where T : Hashable {
        updateEnabled()
        milestonesDidChange?(milestones)
    }
    
    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, didDeselectItem item: T) where T : Hashable {
        updateEnabled()
        milestonesDidChange?(milestones)
    }
}
