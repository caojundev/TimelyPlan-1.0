//
//  HabitTimePlanRandomSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/5.
//

import Foundation
import UIKit

class HabitTimePlanRandomSectionController: TPTableItemSectionController {
   
    /// 规则变化回调
    var ruleDidChange: ((HabitTimePlanRandomRule) -> Void)?
    
    /// 周期目标对象
    var rule: HabitTimePlanRandomRule {
        get {
            return HabitTimePlanRandomRule(frequency: frequency, days: targetDays)
        }
        
        set {
            self.frequency = newValue.frequency
            self.targetDays = newValue.days
        }
    }
    
    private var frequency: RepeatFrequency = .weekly
    
    private var targetDays: Int = 1
    
    /// 重复频率
    private let frequencies: [RepeatFrequency] = [.weekly, .monthly]
    
    /// 频率单元格条目
    lazy var frequencyCellItem: TPFullSizeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = kInsetGroupedSegmentedMenuCornerRadius
        cellItem.menuItems = frequencies.segmentedMenuItems()
        cellItem.updater = {
            self?.updateFrequencyCellItem()
        }
        
        cellItem.didSelectMenuItem = { menuItem in
            let frequency = RepeatFrequency(rawValue: menuItem.tag) ?? .weekly
            self?.didSelectFrequency(frequency)
        }
        
        return cellItem
    }()
    
    /// 目标天数
    lazy var targetDaysCellItem: TPCountPickerTableCellItem = { [weak self] in
        let cellItem = TPCountPickerTableCellItem()
        cellItem.height = 240.0
        cellItem.updater = {
            self?.updateTargetDaysCellItem()
        }
        
        cellItem.didPickCount = { count in
            self?.didSelectTargetDays(count)
        }
        
        cellItem.tailingTextForCount = { count in
            return RepeatFrequency.daily.localizedUnit(for: count)
        }
        
        return cellItem
    }()
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            return [frequencyCellItem, targetDaysCellItem]
        }
        
        set {}
    }
    
    func updateFrequencyCellItem() {
        self.frequencyCellItem.selectedMenuTag = self.frequency.rawValue
    }
    
    func updateTargetDaysCellItem() {
        self.targetDaysCellItem.minimumCount = 1
        if self.frequency == .weekly {
            self.targetDaysCellItem.maximumCount = 7
        } else {
            self.targetDaysCellItem.maximumCount = 30
        }
        
        self.targetDaysCellItem.count = self.targetDays
    }

    func didSelectFrequency(_ frequency: RepeatFrequency) {
        self.frequency = frequency
        self.targetDays = 1
        self.adapter?.reloadCell(forItem: self.targetDaysCellItem, with: .none)
        self.ruleDidChange?(self.rule)
    }
    
    func didSelectTargetDays(_ days: Int) {
        self.targetDays = days
        self.ruleDidChange?(self.rule)
        self.adapter?.performNilUpdate() /// 更新行高度
    }
}
