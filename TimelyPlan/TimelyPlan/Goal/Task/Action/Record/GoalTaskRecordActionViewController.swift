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
    
    /// 区块日期标题高度
    private static let dayHeaderHeight = 34.0
    
    /// 区块日期标题内间距
    private static let dayHeaderPadding = UIEdgeInsets(top: 8.0,
                                                       left: 16.0,
                                                       bottom: 0.0,
                                                       right: 16.0)
    
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
            self?.rebuildSections()
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
        
        var controllers = [TPTableItemSectionController]()
        for group in dayGroups {
            controllers.append(sectionController(for: group))
        }
        
        self.sectionControllers = controllers
        self.reloadData()
    }
    
    /// 为某一天的记录创建区块
    private func sectionController(for group: GoalRecordDayGroup) -> TPTableItemSectionController {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = GoalTaskRecordActionViewController.dayHeaderHeight
        sectionController.headerItem.padding = GoalTaskRecordActionViewController.dayHeaderPadding
        sectionController.headerItem.titleConfig.font = .boldSystemFont(ofSize: 13.0)
        sectionController.headerItem.titleConfig.textColor = resGetColor(.title)
        sectionController.headerItem.title = group.title
        sectionController.footerItem.height = 0.0
        
        sectionController.cellItems = group.rows.map { row in
            return self.cellItem(for: row)
        }
        
        return sectionController
    }
    
    /// 创建记录单元格
    private func cellItem(for row: GoalRecordRowPresentation) -> TPDefaultInfoTextValueTableCellItem {
        let cellItem = TPDefaultInfoTextValueTableCellItem()
        cellItem.selectionStyle = .none
        cellItem.height = 55.0
        cellItem.title = row.time
        cellItem.subtitle = row.note
        cellItem.subtitleConfig.textColor = .secondaryLabel
        cellItem.updater = {
            cellItem.title = row.time
            cellItem.subtitle = row.note
            cellItem.valueConfig = .valueText(row.amountText, textColor: row.amountTextColor)
        }
        
        return cellItem
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
