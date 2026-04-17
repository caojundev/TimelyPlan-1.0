//
//  TodoTaskQuickAddSettingView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/27.
//

import Foundation

class TodoTaskQuickAddSettingView: TPBasePopoverView,
                                    TPTableSectionControllersList {
    
    var sectionControllers: [TPTableBaseSectionController]?
    
    // MARK: -
    lazy var sectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 0.0
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [addContinuouslyCellItem]
        return sectionController
    }()
    
    /// 连续添加
    lazy var addContinuouslyCellItem: TPCheckmarkTableCellItem = { [weak self] in
        let cellItem = TPCheckmarkTableCellItem(autoResizable: false)
        cellItem.title = resGetString("Add Continuously")
        cellItem.imageContent = .withName("todo_task_quickAdd_continuously_24")
        cellItem.titleConfig.font = BOLD_SYSTEM_FONT
        cellItem.height = 55.0
        cellItem.updater = {
            let isOn = TodoSetting.shared.quickAddContinuously
            self?.addContinuouslyCellItem.isChecked = isOn
        }

        cellItem.didSelectHandler = { [weak self] in
            self?.toggleAddContinuously()
        }
        
        return cellItem
    }()
    
    lazy var settingsView: TPTableWrapperView = {
        let tableView = TPTableWrapperView(frame: contentView.bounds, style: .grouped)
        tableView.tableView.separatorStyle = .none
        tableView.backgroundColor = .secondarySystemGroupedBackground
        tableView.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        tableView.adapter.dataSource = self
        tableView.adapter.delegate = self
        return tableView
    }()
    
    var adapter: TPTableViewAdapter {
        return settingsView.adapter
    }
    
    
    override func setupSubviews() {
        super.setupSubviews()
        self.popoverView = self.settingsView
        self.sectionControllers = [self.sectionController]
        self.settingsView.reloadData()
    }
    
    override var popoverContentSize: CGSize {
        var contentSize = self.settingsView.contentSize
        contentSize.width = 240.0
        return contentSize
    }

    // MARK: -
    func toggleAddContinuously() {
        let isOn = !addContinuouslyCellItem.isChecked
        TodoSetting.shared.quickAddContinuously = isOn
        self.addContinuouslyCellItem.isChecked = isOn
        self.adapter.reloadCell(forItem: addContinuouslyCellItem, with: .none)
        
        var message: String
        if isOn {
            message = resGetString("Continuous adding enabled")
        } else {
            message = resGetString("Continuous adding disabled")
        }

        TPFeedbackQueue.common.postFeedback(text: message, position: .top)
        self.hide(animated: true)
    }
}
