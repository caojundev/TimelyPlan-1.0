//
//  GoalTaskProgressEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/5.
//

import Foundation
import UIKit

/// 目标任务进度编辑区块
/// 负责展示与编辑任务的进度数值（开始/目标数值、计算方式、记录方式、自动记录数值），
/// 数据变更时通过回调通知外部（由外部同步到数据模型）。
class GoalTaskProgressEditSectionController: TPTableItemSectionController {
    
    /// 开始数值改变回调
    var onInitialValueChanged: ((Int64) -> Void)?
    
    /// 目标数值改变回调
    var onTargetValueChanged: ((Int64) -> Void)?
    
    /// 计算方式改变回调
    var onCalculationChanged: ((GoalProgressCalculation) -> Void)?
    
    /// 记录方式改变回调
    var onRecordTypeChanged: ((GoalProgressRecordType) -> Void)?
    
    /// 自动记录数值改变回调
    var onAutoRecordValueChanged: ((Int?) -> Void)?
    
    /// 开始数值
    var initialValue: Int64 = 0
    
    /// 目标数值
    var targetValue: Int64 = 0
    
    /// 计算方式
    var calculation: GoalProgressCalculation = .sum
    
    /// 记录方式
    var recordType: GoalProgressRecordType = .manual
    
    /// 自动记录数值
    var autoRecordValue: Int?
    
    // MARK: - 单元格
    /// 开始数值单元格
    lazy var initialValueCellItem: TPNumberFieldTableCellItem = { [weak self] in
        let cellItem = TPNumberFieldTableCellItem()
        cellItem.title = resGetString("Initial Value")
        cellItem.fieldCornerRadius = .greatestFiniteMagnitude
        cellItem.updater = {
            guard let self = self else { return }
            self.initialValueCellItem.number = NSNumber(value: self.initialValue)
        }
        
        cellItem.didEndEditing = { [weak self] number in
            self?.didEndEditInitialValue(number.int64Value)
        }
        
        return cellItem
    }()
    
    /// 目标数值单元格
    lazy var targetValueCellItem: TPNumberFieldTableCellItem = { [weak self] in
        let cellItem = TPNumberFieldTableCellItem()
        cellItem.title = resGetString("Target Value")
        cellItem.fieldCornerRadius = .greatestFiniteMagnitude
        cellItem.updater = {
            guard let self = self else { return }
            self.targetValueCellItem.number = NSNumber(value: self.targetValue)
        }
        
        cellItem.didEndEditing = { [weak self] number in
            self?.didEndEditTargetValue(number.int64Value)
        }
        
        return cellItem
    }()
    
    /// 计算方式单元格
    lazy var calculationCellItem: TPSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPSegmentedMenuTableCellItem()
        cellItem.title = resGetString("Calculation")
        cellItem.cornerRadius = .greatestFiniteMagnitude
        cellItem.menuPadding = UIEdgeInsets(value: 2.0)
        cellItem.menuItems = GoalProgressCalculation.segmentedMenuItems(style: .title)
        cellItem.updater = {
            guard let self = self else { return }
            self.calculationCellItem.selectedMenuTag = self.calculation.tag
        }
        
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            guard let calculation = GoalProgressCalculation(rawValue: menuItem.tag) else {
                return
            }
            
            self?.setCalculation(calculation)
        }
        
        return cellItem
    }()
    
    /// 记录方式单元格
    lazy var recordTypeCellItem: TPSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPSegmentedMenuTableCellItem()
        cellItem.title = resGetString("Record Type")
        cellItem.cornerRadius = .greatestFiniteMagnitude
        cellItem.menuPadding = UIEdgeInsets(value: 2.0)
        cellItem.menuItems = GoalProgressRecordType.segmentedMenuItems(style: .title)
        cellItem.updater = {
            guard let self = self else { return }
            self.updateRecordTypeCellItem()
        }
        
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            guard let recordType = GoalProgressRecordType(rawValue: menuItem.tag) else {
                return
            }
            
            self?.setRecordType(recordType)
        }
        
        return cellItem
    }()
    
    /// 自动记录数值单元格
    lazy var autoRecordValueCellItem: TPNumberFieldLeftSymbolTableCellItem = { [weak self] in
        let cellItem = TPNumberFieldLeftSymbolTableCellItem()
        cellItem.title = resGetString("Auto Record Value")
        cellItem.fieldPadding = UIEdgeInsets(left: 15.0, right: 10.0)
        cellItem.fieldCornerRadius = .greatestFiniteMagnitude
        cellItem.updater = {
            guard let self = self else { return }
            self.updateAutoRecordValueCellItem()
        }
        
        cellItem.didEndEditing = { [weak self] number in
            self?.didEndEditAutoRecordValue(number.int64Value)
        }
        
        return cellItem
    }()
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            var cellItems = [initialValueCellItem,
                             targetValueCellItem,
                             calculationCellItem]
            guard calculation != .update else {
                return cellItems
            }
            
            cellItems.append(recordTypeCellItem)
            if recordType == .auto {
                cellItems.append(autoRecordValueCellItem)
            }
            
            return cellItems
        }
        
        set {}
    }
    
    override init() {
        super.init()
        self.headerItem.height = 20.0
        self.footerItem.height = 0.0
    }
    
    // MARK: - Update
    /// 更新记录类型单元格
    private func updateRecordTypeCellItem() {
        recordTypeCellItem.selectedMenuTag = recordType.tag
        recordTypeCellItem.isDisabled = calculation == .update
    }
    
    /// 更新自动记录数值单元格
    private func updateAutoRecordValueCellItem() {
        autoRecordValueCellItem.leftSymbol = targetValue >= initialValue ? "+" : "-"
        
        var autoRecordValue = self.autoRecordValue ?? 1
        if autoRecordValue <= 0 {
            autoRecordValue = 1
        }
        
        autoRecordValueCellItem.number = NSNumber(value: autoRecordValue)
    }
    
    /// 刷新自动记录数值单元格（记录方式为自动时才存在）
    private func reloadAutoRecordValueCellItemIfNeeded() {
        guard recordType == .auto else {
            return
        }
        
        adapter?.reloadCell(forItem: autoRecordValueCellItem, with: .none)
    }
    
    // MARK: - Event Response
    /// 设置计算方式
    func setCalculation(_ calculation: GoalProgressCalculation) {
        guard self.calculation != calculation else {
            return
        }
        
        self.calculation = calculation
        if calculation == .update {
            self.recordType = .manual
            onRecordTypeChanged?(.manual)
        }
        
        onCalculationChanged?(calculation)
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
    }
    
    /// 设置记录方式
    func setRecordType(_ recordType: GoalProgressRecordType) {
        guard self.recordType != recordType else {
            return
        }
        
        self.recordType = recordType
        if recordType == .manual {
            self.autoRecordValue = nil
            onAutoRecordValueChanged?(nil)
        }
        
        onRecordTypeChanged?(recordType)
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
    }
    
    /// 结束编辑开始数值
    func didEndEditInitialValue(_ value: Int64) {
        guard initialValue != value, targetValue != value else {
            adapter?.reloadCell(forItem: initialValueCellItem, with: .none)
            return
        }
        
        initialValue = value
        onInitialValueChanged?(value)
        adapter?.reloadCell(forItems: [initialValueCellItem, targetValueCellItem], with: .none)
        reloadAutoRecordValueCellItemIfNeeded()
    }
    
    /// 结束编辑目标数值
    func didEndEditTargetValue(_ value: Int64) {
        guard initialValue != value, targetValue != value else {
            adapter?.reloadCell(forItem: targetValueCellItem, with: .none)
            return
        }
        
        targetValue = value
        onTargetValueChanged?(value)
        adapter?.reloadCell(forItems: [targetValueCellItem, initialValueCellItem], with: .none)
        reloadAutoRecordValueCellItemIfNeeded()
    }
    
    /// 结束编辑自动记录数值
    func didEndEditAutoRecordValue(_ value: Int64) {
        let autoRecordValue = value == 0 ? nil : Int(value)
        self.autoRecordValue = autoRecordValue
        onAutoRecordValueChanged?(autoRecordValue)
    }
}
