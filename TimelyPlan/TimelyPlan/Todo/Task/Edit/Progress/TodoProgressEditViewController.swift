//
//  TodoProgressEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/5.
//

import Foundation
import UIKit

class TodoProgressEditViewController: TPTableSectionsViewController {
   
    /// 量化对象结束编辑回调
    var didEndEditing: ((TodoEditProgress?) -> Void)?
    
    /// 初始值
    lazy var initialValueCellItem: TPNumberFieldTableCellItem = { [weak self] in
        let cellItem = TPNumberFieldTableCellItem()
        cellItem.imageName = "todo_task_progress_initialValue_24"
        cellItem.title = resGetString("Initial Value")
        cellItem.fieldCornerRadius = 12.0
        cellItem.updater = {
            guard let self = self else { return }
            let value = self.progress.initialValue
            self.initialValueCellItem.number = NSNumber(value: value)
        }
        
        cellItem.didEndEditing = { number in
            self?.didEndEditingInitialValue(number.int64Value)
        }
        
        return cellItem
    }()
    
    /// 目标值
    lazy var targetValueCellItem: TPNumberFieldTableCellItem = { [weak self] in
        let cellItem = TPNumberFieldTableCellItem()
        cellItem.imageName = "todo_task_progress_targetValue_24"
        cellItem.title = resGetString("Target Value")
        cellItem.fieldCornerRadius = 12.0
        cellItem.updater = {
            guard let self = self else { return }
            let value = self.progress.targetValue
            self.targetValueCellItem.number = NSNumber(value: value)
        }
    
        cellItem.didEndEditing = { number in
            self?.didEndEditingTargetValue(number.int64Value)
        }
        
        return cellItem
    }()
    
    /// 数值区块
    lazy var valueRangeSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.setupSeparatorFooterItem(backgroundColor: .systemBackground)
        sectionController.cellItems = [initialValueCellItem,
                                       targetValueCellItem]
        return sectionController
    }()
    
    
    /// 当前值
    lazy var currentValueCellItem: TPNumberFieldTableCellItem = { [weak self] in
        let cellItem = TPNumberFieldTableCellItem()
        cellItem.imageName = "todo_task_progress_currentValue_24"
        cellItem.title = resGetString("Current Value")
        cellItem.fieldCornerRadius = 12.0
        cellItem.updater = {
            guard let self = self else { return }
            let value = self.progress.currentValue
            self.currentValueCellItem.number = NSNumber(value: value)
        }
    
        cellItem.didEndEditing = { number in
            self?.didEndEditingCurrentValue(number.int64Value)
        }
    
        return cellItem
    }()

    /// 当前值区块
    lazy var currentValueSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.setupSeparatorFooterItem(backgroundColor: .systemBackground)
        sectionController.cellItems = [currentValueCellItem]
        return sectionController
    }()
    
    
    // MARK: - 计算

    lazy var calculationCellItem: TPSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPSegmentedMenuTableCellItem()
        cellItem.imageName = "todo_task_progress_calculation_24"
        cellItem.title = resGetString("Calculation")
        cellItem.cornerRadius = 12.0
        cellItem.menuPadding = UIEdgeInsets(value: 2.0)
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
        sectionController.setupSeparatorFooterItem(backgroundColor: .systemBackground)
        return sectionController
    }()
    
    // MARK: - 记录
    
    /// 记录方式
    lazy var recordTypeCellItem: TPSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPSegmentedMenuTableCellItem()
        cellItem.imageName = "todo_task_progress_recordType_24"
        cellItem.title = resGetString("Record Type")
        cellItem.cornerRadius = 12.0
        cellItem.menuPadding = UIEdgeInsets(value: 2.0)
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
    lazy var autoRecordValueCellItem: TPNumberFieldLeftSymbolTableCellItem = { [weak self] in
        let cellItem = TPNumberFieldLeftSymbolTableCellItem()
        cellItem.imageName = "todo_task_progress_autoRecordValue_24"
        cellItem.title = resGetString("Auto Record Value")
        cellItem.fieldPadding = UIEdgeInsets(left: 15.0, right: 10.0)
        cellItem.fieldCornerRadius = 12.0
        cellItem.updater = {
            self?.updateAutoRecordValueCellItem()
        }
        
        cellItem.didEndEditing = { number in
            self?.didEndEditingAutoRecordValue(number.int64Value)
        }
        
        return cellItem
    }()

    /// 记录区块
    lazy var recordSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 0.0
        return sectionController
    }()

    lazy var resetBarButtonItem: UIBarButtonItem = {
        let image = resGetImage("todo_task_progress_reset_24")
        let item = UIBarButtonItem(image: image,
                                   style: .done,
                                   target: self,
                                   action: #selector(clickReset))
        return item
    }()
    
    /// 清除按钮
    private lazy var clearBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: resGetImage("clear_24"),
                                   style: .done,
                                   target: self,
                                   action: #selector(clickClear))
        item.tintColor = .redPrimary
        return item
    }()
    
    var progress: TodoEditProgress
   
    var showClearButton: Bool
    
    init(progress: TodoEditProgress? = nil) {
        self.showClearButton = progress != nil
        self.progress = progress ?? TodoEditProgress()
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Progress")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        var rightBarButtonItems = [resetBarButtonItem]
        if showClearButton {
            rightBarButtonItems.insert(clearBarButtonItem, at: 0)
        }
        
        self.navigationItem.rightBarButtonItems = rightBarButtonItems
        self.preferredContentSize = .Popover.extraLarge
        setupActionsBar(actions: [doneAction])
        tableView.keyboardDismissMode = .onDrag
        wrapperView.isKeyboardAdjusterEnabled = true
        updateRecordSectionController()
        sectionControllers = [valueRangeSectionController,
                              currentValueSectionController,
                              calculationSectionController,
                              recordSectionController]
        adapter.cellStyle.backgroundColor = .systemBackground
        adapter.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
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
            leftSymbol = "-"
        } else {
            leftSymbol = "+"
        }
        
        autoRecordValueCellItem.leftSymbol = leftSymbol
        
        var autoRecordValue = progress.autoRecordValue
        if autoRecordValue <= 0 {
            autoRecordValue = 1
        }
        
        autoRecordValueCellItem.number = NSNumber(value: autoRecordValue)
    }
    
    /// 更新单元格数字
    private func updateNumber(for cellItem: TPNumberFieldTableCellItem) {
        guard let cell = adapter.cellForItem(cellItem) as? TPNumberFieldTableCell else {
            return
        }
        
        cell.updateNumber()
    }
    
    
    // MARK: - Event Response
    override func clickDone() {
        super.clickDone()
        didEndEditing?(progress)
    }
    
    @objc private func clickClear() {
        TPImpactFeedback.impactWithSoftStyle()
        dismiss(animated: true, completion: nil)
        didEndEditing?(nil)
    }
    
    @objc private func clickReset() {
        TPImpactFeedback.impactWithSoftStyle()
        progress.resetCurrentValue()
        updateNumber(for: currentValueCellItem)
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
