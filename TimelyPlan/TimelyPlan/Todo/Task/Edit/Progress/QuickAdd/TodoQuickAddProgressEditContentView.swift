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
    
    var sectionControllers: [TPTableBaseSectionController]?

    var progress: TodoEditProgress

    init(progress: TodoEditProgress? = nil) {
        self.progress = progress ?? TodoEditProgress()
        super.init(frame: .zero, style: .grouped)
        self.tableView.separatorStyle = .none
        self.tableView.separatorInset = UIEdgeInsets(horizontal: 16.0)
        self.tableView.separatorColor = .systemGray6
        self.tableView.showsVerticalScrollIndicator = false
        self.sectionControllers = [valueSectionController]
        self.adapter.cellStyle.backgroundColor = .secondarySystemBackground
        self.adapter.delegate = self
        self.adapter.dataSource = self
        self.adapter.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Update
    func didEndEditingInitialValue(_ value: Int64) {
        if progress.initialValue != value {
            progress.initialValue = value
            progressValueChanged?(progress)
        }
    }
    
    func didEndEditingTargetValue(_ value: Int64) {
        if progress.targetValue != value {
            progress.targetValue = value
            progressValueChanged?(progress)
        }
    }
    
    func didEndEditingCurrentValue(_ value: Int64) {
        if progress.currentValue != value {
            progress.currentValue = value
            progressValueChanged?(progress)
        }
    }
}
