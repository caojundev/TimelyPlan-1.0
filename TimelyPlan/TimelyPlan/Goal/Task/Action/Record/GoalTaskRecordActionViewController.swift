//
//  GoalTaskRecordActionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/9.
//

import Foundation
import UIKit

/// 目标任务「记录」操作内容视图控制器
///
/// 使用 UITableView 展示任务对应的全部 `GoalRecord`，
/// 数据由 `GoalRecordListViewModel` 提供，记录按天分组，
/// 每个区块（section）显示某一天的记录。
class GoalTaskRecordActionViewController: TPTableSectionsViewController {
    
    /// 空记录占位图
    private static let emptyPlaceholder = resGetString("No Goal Record")
    
    /// 记录列表 ViewModel
    private let viewModel: GoalRecordListViewModel
    
    init(task: GoalTask) {
        self.viewModel = GoalRecordListViewModel(task: task)
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.keyboardDismissMode = .onDrag
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        
        self.viewModel.didChangeRecords = { [weak self] in
            DispatchQueue.main.async {
                self?.rebuildSections()
            }
        }
        /// 首次加载记录
        self.viewModel.reload()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - Sections
    
    /// 依据 ViewModel 的分组数据重建区块
    private func rebuildSections() {
        let dayGroups = viewModel.dayGroups
        guard dayGroups.count > 0 else {
            self.sectionControllers = [emptySectionController]
            self.reloadData()
            return
        }
        
        let controllers: [TPTableBaseSectionController] = dayGroups.map { group in
            let sectionController = GoalTaskRecordDaySectionController(date: group.date,
                                                                       title: group.title,
                                                                       rows: group.rows)
            sectionController.onDeleteRecord = { [weak self] identifier in
                self?.viewModel.deleteRecord(withIdentifier: identifier)
            }
            return sectionController as TPTableBaseSectionController
        }
        
        self.sectionControllers = controllers
        self.adapter.performUpdate(with: .fade)
    }
    
    /// 空记录占位区块
    private var emptySectionController: TPTableItemSectionController {
        let placeholder = TFPlaceholderTableCellItem()
        placeholder.placeholderTitle = GoalTaskRecordActionViewController.emptyPlaceholder
        let sectionController = TPTableItemSectionController()
        sectionController.cellItems = [placeholder]
        return sectionController
    }
}
