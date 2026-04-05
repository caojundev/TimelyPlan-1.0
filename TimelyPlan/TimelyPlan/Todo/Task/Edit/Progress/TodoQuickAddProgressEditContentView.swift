//
//  TodoProgressEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/5.
//

import Foundation
import UIKit

class TodoQuickAddProgressEditContentView: TPTableWrapperView,
                                           TPTableSectionControllersList,
                                           TPTableSectionControllerDelegate {

    var progressValueChanged: ((TodoEditProgress) -> Void)?
    
    /// 初始值
    lazy var initialValueCellItem: TodoQuickAddProgressValueCellItem = { [weak self] in
        let cellItem = TodoQuickAddProgressValueCellItem()
        cellItem.imageName = "todo_task_progress_initialValue_24"
        cellItem.title = resGetString("Initial Value")
        cellItem.updater = {
            guard let self = self else { return }
            let value = self.progress.initialValue
            self.initialValueCellItem.value = value
        }
        
        cellItem.valueChanged = { value in
            self?.didEndEditingInitialValue(value)
        }
        
        return cellItem
    }()
    
    /// 目标值
    lazy var targetValueCellItem: TodoQuickAddProgressValueCellItem = { [weak self] in
        let cellItem = TodoQuickAddProgressValueCellItem()
        cellItem.imageName = "todo_task_progress_targetValue_24"
        cellItem.title = resGetString("Target Value")
        cellItem.updater = {
            guard let self = self else { return }
            let value = self.progress.targetValue
            self.targetValueCellItem.value = value
        }
        
        cellItem.valueChanged = { value in
            self?.didEndEditingTargetValue(value)
        }
        
        return cellItem
    }()

    /// 当前值
    lazy var currentValueCellItem: TodoQuickAddProgressValueCellItem = { [weak self] in
        let cellItem = TodoQuickAddProgressValueCellItem()
        cellItem.imageName = "todo_task_progress_currentValue_24"
        cellItem.title = resGetString("Current Value")
        cellItem.updater = {
            guard let self = self else { return }
            let value = self.progress.currentValue
            self.currentValueCellItem.value = value
        }
        
        cellItem.valueChanged = { value in
            self?.didEndEditingCurrentValue(value)
        }
        
        return cellItem
    }()
    
    /// 当前值区块
    lazy var valueSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.cellItems = [initialValueCellItem,
                                       targetValueCellItem,
                                       currentValueCellItem]
        return sectionController
    }()
    
    // MARK: - 计算
    lazy var calculationCellItem: TodoQuickAddProgressSegmentedCellItem = { [weak self] in
        let cellItem = TodoQuickAddProgressSegmentedCellItem()
        cellItem.imageName = "todo_task_progress_calculation_24"
        cellItem.title = resGetString("Calculation")
        cellItem.menuItems = TodoProgressCalculation.segmentedMenuItems()
        cellItem.updater = {
            guard let self = self else { return }
            let calculation = self.progress.calculation
            self.calculationCellItem.selectedMenuTag = calculation.tag
        }
        
        cellItem.didSelectMenuItem = { menuItem in
            guard let calculation = TodoProgressCalculation(rawValue: menuItem.tag) else {
                return
            }

            self?.didSelectCalculation(calculation)
        }
        
        return cellItem
    }()
    
    /// 计算区块
    lazy var calculationSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 0.0
        sectionController.cellItems = [calculationCellItem]
        return sectionController
    }()
    
    // MARK: - 记录
    
    /// 记录方式
    lazy var recordTypeCellItem: TodoQuickAddProgressSegmentedCellItem = { [weak self] in
        let cellItem = TodoQuickAddProgressSegmentedCellItem()
        cellItem.imageName = "todo_task_progress_recordType_24"
        cellItem.title = resGetString("Record Type")
        cellItem.menuItems = TodoProgressRecordType.segmentedMenuItems()
        cellItem.updater = {
            self?.updateRecordTypeCellItem()
        }
        
        cellItem.didSelectMenuItem = { menuItem in
            guard let recordType = TodoProgressRecordType(rawValue: menuItem.tag) else {
                return
            }

            self?.didSelectRecordType(recordType)
        }
        
        return cellItem
    }()

    /// 自动记录
    lazy var autoRecordValueCellItem: TodoQuickAddProgressValueCellItem = { [weak self] in
        let cellItem = TodoQuickAddProgressValueCellItem()
        cellItem.imageName = "todo_task_progress_autoRecordValue_24"
        cellItem.title = resGetString("Auto Record Value")
        cellItem.minValue = 1
        cellItem.shouldShowSign = true
        cellItem.updater = {
            self?.updateAutoRecordValueCellItem()
        }
        
        cellItem.valueChanged = { value in
            self?.didEndEditingAutoRecordValue(value)
        }
        
        return cellItem
    }()

    /// 记录区块
    lazy var recordSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 0.0
        return sectionController
    }()
    
    var sectionControllers: [TPTableBaseSectionController]?

    var progress: TodoEditProgress

    init(progress: TodoEditProgress? = nil) {
        self.progress = progress ?? TodoEditProgress()
        super.init(frame: .zero, style: .grouped)
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorInset = UIEdgeInsets(horizontal: 8.0)
        self.tableView.separatorColor = .systemGray5
        self.tableView.showsVerticalScrollIndicator = false
        self.updateRecordSectionController()
        self.sectionControllers = [valueSectionController,
                                   calculationSectionController,
                                   recordSectionController]
        self.adapter.cellStyle.backgroundColor = .secondarySystemBackground
        self.adapter.delegate = self
        self.adapter.dataSource = self
        self.adapter.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Update
    
    private func updateRecordSectionController() {
        guard progress.calculation != .update else {
            recordSectionController.cellItems = nil
            return
        }
        
        let recordType = progress.recordType
        var recordCellItems: [TPBaseTableCellItem] = [recordTypeCellItem]
        if recordType == .auto {
            recordCellItems.append(autoRecordValueCellItem)
        }
        
        recordSectionController.cellItems = recordCellItems
    }
    
    func updateRecordTypeCellItem() {
        let recordType = progress.recordType
        recordTypeCellItem.selectedMenuTag = recordType.tag
        recordTypeCellItem.isDisabled = progress.calculation == .update
    }
    
    private func updateAutoRecordValueCellItem() {
        var leftSymbol: Character
        if progress.initialValue > progress.targetValue {
            autoRecordValueCellItem.isNegativeValue = true
        } else {
            autoRecordValueCellItem.isNegativeValue = false
        }

        var autoRecordValue = progress.autoRecordValue
        if autoRecordValue <= 0 {
            autoRecordValue = 1
        }
        
        autoRecordValueCellItem.value = autoRecordValue
    }
    
    /// 更新单元格数字
    private func updateNumber(for cellItem: TPNumberFieldTableCellItem) {
        guard let cell = adapter.cellForItem(cellItem) as? TPNumberFieldTableCell else {
            return
        }
        
        cell.updateNumber()
    }
    

    func didEndEditingInitialValue(_ value: Int64) {
        guard value != progress.initialValue else {
            return
        }
        
        progress.initialValue = value
        reloadCurrentAndAutoRecordValueCell()
    }
    
    func didEndEditingTargetValue(_ value: Int64) {
        guard value != progress.targetValue else {
            return
        }
        
        progress.targetValue = value
        reloadCurrentAndAutoRecordValueCell()
    }
    
    func didEndEditingCurrentValue(_ value: Int64) {
        progress.currentValue = value
    }
    
    func didEndEditingAutoRecordValue(_ value: Int64) {
        if progress.autoRecordValue != value {
            progress.autoRecordValue = value
        }
    }

    func didSelectCalculation(_ calculation: TodoProgressCalculation) {
        if progress.calculation != calculation {
            progress.calculation = calculation
            
            /// 更新记录区块
            updateRecordSectionController()
            adapter.performSectionUpdate(forSectionObject: recordSectionController, rowAnimation: .top)
        }
    }
    
    func didSelectRecordType(_ recordType: TodoProgressRecordType) {
        if progress.recordType != recordType {
            progress.recordType = recordType
            
            /// 更新记录区块
            updateRecordSectionController()
            adapter.performSectionUpdate(forSectionObject: recordSectionController, rowAnimation: .top)
        }
    }
    
    // MARK: - Reload
    private func reloadCurrentAndAutoRecordValueCell() {
        var cellItems: [TPBaseTableCellItem] = [currentValueCellItem]
        if progress.recordType == .auto {
            cellItems.append(autoRecordValueCellItem)
        }
        
        adapter.reloadCell(forItems: cellItems, with: .none)
    }
}
