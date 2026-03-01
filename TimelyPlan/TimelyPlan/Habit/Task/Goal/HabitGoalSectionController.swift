//
//  HabitGoalSectionController.swift
//  TimelyPlan
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
        cellItem.menuItems = HabitGoal.TargetMode.segmentedMenuItems()
        cellItem.updater = {
            guard let self = self else {
                return
            }
            
            let mode = self.goal.mode ?? .checkin
            self.targetModeCellItem.selectedMenuTag = mode.rawValue
        }
        
        cellItem.didSelectMenuItem = { menuItem in
            guard let mode = HabitGoal.TargetMode(rawValue: menuItem.tag) else {
                return
            }
            
            self?.didSelectTargetMode(mode)
        }
        
        return cellItem
    }()
    
    /// 目标数值
    lazy var targetAmountCellItem: HabitGoalTargetEditCellItem = { [weak self] in
        let cellItem = HabitGoalTargetEditCellItem()
        cellItem.title = resGetString("Daily Target")
        cellItem.updater = {
            guard let self = self else {
                return
            }
            
            self.targetAmountCellItem.number = NSNumber(value: self.goal.validatedTargetAmount)
            self.targetAmountCellItem.unit = self.goal.validatedUnit
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
            self.recordTypeCellItem.recordType = self.goal.recordType ?? .completeAll
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
            let amount = self.goal.validatedRecordAmount
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
            if goal.mode == .amount {
                cellItems.append(targetAmountCellItem)
                cellItems.append(recordTypeCellItem)
                let recordType = goal.recordType ?? .completeAll
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
    func didSelectTargetMode(_ mode: HabitGoal.TargetMode) {
        goal.mode = mode
        goalDidChange?(goal)
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
    }
    
    /// 目标数值改变
    func targetAmountDidChange(_ number: NSNumber) {
        goal.targetAmount = number.intValue
        targetAmountCellItem.updater?()
        goalDidChange?(goal)
    }
    
    /// 目标单位改变
    func targetUnitDidChange(_ unit: String) {
        goal.unit = unit
        targetAmountCellItem.updater?()
        goalDidChange?(goal)
    }
    
    func didEndEditingAutoRecord(number: NSNumber) {
        goal.recordAmount = number.intValue
        autoRecordNumberCellItem.updater?()
        goalDidChange?(goal)
    }
    
    private func didSelectRecordType(_ type: HabitGoal.RecordType) {
        goal.recordType = type
        recordTypeCellItem.updater?()
        goalDidChange?(goal)
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
    }
}
