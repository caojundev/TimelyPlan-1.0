//
//  HabitGoalSectionController.swift
//  iTimeFlow
//
//  Created by caojun on 2024/3/23.
//

import Foundation

class HabitGoalSectionController: TPTableItemSectionController {
    
    var goal: HabitGoal = HabitGoal()
    
    var goalDidChange: ((HabitGoal) -> Void)?
    
    /// 目标模式
    lazy var targetModeCellItem: TPFullSizeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = kInsetGroupedSegmentedMenuCornerRadius
        cellItem.menuItems = HabitGoal.Target.Mode.segmentedMenuItems()
        cellItem.updater = {
            guard let self = self else {
                return
            }
            
            let mode = self.goal.target.mode ?? .checkin
            self.targetModeCellItem.selectedMenuTag = mode.rawValue
        }
        
        cellItem.didSelectMenuItem = { menuItem in
            guard let mode = HabitGoal.Target.Mode(rawValue: menuItem.tag) else {
                return
            }
            
            self?.didSelectTargetMode(mode)
        }
        
        return cellItem
    }()
    
    /// 目标数值
    lazy var targetAmountCellItem: HabitGoalTargetAmountCellItem = { [weak self] in
        let cellItem = HabitGoalTargetAmountCellItem()
        cellItem.title = resGetString("Daily Target")
        cellItem.updater = {
            guard let self = self else {
                return
            }
            
            self.targetAmountCellItem.number = NSNumber(value: self.goal.targetAmount)
            self.targetAmountCellItem.unit = self.goal.targetUnit
        }
        
        cellItem.didEndEditing = { number in
            self?.targetAmountDidChange(number)
        }
        
        cellItem.unitDidChange = { unit in
            self?.targetUnitDidChange(unit)
        }
        
        return cellItem
    }()
    
    /// 记录方式
    lazy var recordTypeCellItem: HabitRecordTypeEditCellItem = { [weak self] in
        let cellItem = HabitRecordTypeEditCellItem()
        cellItem.height = 66.0
        cellItem.title = resGetString("Record Type")
        cellItem.updater = {
            guard let self = self else { return }
            self.recordTypeCellItem.recordType = self.goal.record.type ?? .completeAll
        }
        
        cellItem.didSelectRecordType = { recordType in
            self?.didSelectRecordType(recordType)
        }
        
        return cellItem
    }()

    /// 自动记录
    lazy var autoRecordNumberCellItem: TPNumberFieldTableCellItem = { [weak self] in
        let cellItem = TPNumberFieldTableCellItem()
        cellItem.title = resGetString("Record Value")
        cellItem.updater = {
            guard let self = self else { return }
            let amount = self.goal.autoRecordAmount
            self.autoRecordNumberCellItem.number = NSNumber(value: amount)
        }
        
        cellItem.didEndEditing = { number in
            self?.didEndEditingAutoRecord(number: number)
        }
        
        return cellItem
    }()

    override var cellItems: [TPBaseTableCellItem]? {
        get {
            var cellItems: [TPBaseTableCellItem] = [targetModeCellItem]
            /// 定量模式
            if goal.target.mode == .amount {
                cellItems.append(targetAmountCellItem)
                cellItems.append(recordTypeCellItem)
                let recordType = goal.record.type ?? .completeAll
                if recordType == .automatically {
                    cellItems.append(autoRecordNumberCellItem)
                }
            }
            
            return cellItems
        }
        
        set {}
    }
    
    override init() {
        super.init()
        self.headerItem.height = 50.0
        self.headerItem.title = resGetString("Goal And Record")   
    }
    
    // MARK: - Processor
    /// 选中目标模式
    func didSelectTargetMode(_ mode: HabitGoal.Target.Mode) {
        goal.target.mode = mode
        goalDidChange?(goal)
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
    }
    
    /// 目标数值改变
    func targetAmountDidChange(_ number: NSNumber) {
        goal.target.amount = number.intValue
        targetAmountCellItem.updater?()
        goalDidChange?(goal)
    }
    
    /// 目标单位改变
    func targetUnitDidChange(_ unit: String) {
        goal.target.unit = unit
        targetAmountCellItem.updater?()
        goalDidChange?(goal)
    }
    
    func didEndEditingAutoRecord(number: NSNumber) {
        goal.record.amount = number.intValue
        autoRecordNumberCellItem.updater?()
        goalDidChange?(goal)
    }
    
    private func didSelectRecordType(_ type: HabitGoal.RecordType) {
        goal.record.type = type
        recordTypeCellItem.updater?()
        goalDidChange?(goal)
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
    }
}
