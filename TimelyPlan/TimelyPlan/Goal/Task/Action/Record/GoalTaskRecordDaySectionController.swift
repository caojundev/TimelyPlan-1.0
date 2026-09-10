//
//  GoalTaskRecordDaySectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/9.
//

import Foundation
import UIKit

/// 一天的任务记录区块（分区）
///
/// 继承 `TPTableItemSectionController`，对应某一天的一组目标记录，
/// 区块标题为该天的日期；重写以提供左滑删除菜单。
class GoalTaskRecordDaySectionController: TPTableItemSectionController {
    
    /// 区块日期标题高度
    private static let dayHeaderHeight = 50.0
    
    /// 区块日期标题内间距
    private static let dayHeaderPadding = UIEdgeInsets(top: 8.0,
                                                       left: 8.0,
                                                       bottom: 0.0,
                                                       right: 16.0)
    
    /// 所属日期
    let date: Date
    
    /// 当天的记录展示模型
    private(set) var rows: [GoalRecordRowPresentation]
    
    /// 请求删除某条记录（参数为记录标识）
    var onDeleteRecord: ((String) -> Void)?
    
    /// 点击某条记录请求编辑（用于更新记录数值与备注）
    var onEditRecord: ((GoalRecordRowPresentation) -> Void)?
    
    init(date: Date, title: String, rows: [GoalRecordRowPresentation]) {
        self.date = date
        self.rows = rows
        super.init()
        self.identifier = date.yearMonthDayString
        
        self.headerItem.title = title
        self.headerItem.height = GoalTaskRecordDaySectionController.dayHeaderHeight
        self.headerItem.padding = GoalTaskRecordDaySectionController.dayHeaderPadding
        self.headerItem.titleConfig.font = .boldSystemFont(ofSize: 13.0)
        self.headerItem.titleConfig.textColor = resGetColor(.title)
        self.footerItem.height = 0.0
        
        self.cellItems = rows.map { cellItem(for: $0) }
    }
    
    // MARK: - SwipeActionsConfiguration
    
    /// 左滑提供删除菜单
    override func trailingSwipeActionsConfigurationForRow(at index: Int) -> UISwipeActionsConfiguration? {
        guard index < rows.count else {
            return nil
        }
        
        ///< 删除
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            self.requestDeleteRecord(at: index)
            completion(true)
        }
        
        deleteAction.image = resGetImage("trash_24", color: .white)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - Private
    
    /// 请求删除某条记录前弹确认
    private func requestDeleteRecord(at index: Int) {
        guard index < rows.count else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        let row = rows[index]
        onDeleteRecord?(row.identifier)
        
        /*
        let deleteAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Delete")) { [weak self] _ in
            self?.onDeleteRecord?(row.identifier)
        }
        let cancelAction = TPAlertAction(type: .cancel, title: resGetString("Cancel"))
        let alertController = TPAlertController(title: resGetString("Delete Record"),
                                                message: resGetString("This record will be permanently deleted."),
                                                actions: [cancelAction, deleteAction])
        alertController.show()
        */
    }
    
    /// 创建某条记录的单元格
    private func cellItem(for row: GoalRecordRowPresentation) -> TPDefaultInfoTextValueTableCellItem {
        let cellItem = TPDefaultInfoTextValueTableCellItem()
        cellItem.height = 60.0
        cellItem.title = row.time
        cellItem.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        cellItem.subtitle = row.note
        cellItem.subtitleConfig.textColor = .secondaryLabel
        cellItem.subtitleConfig.font = .systemFont(ofSize: 12.0)
        cellItem.rightViewMargins = UIEdgeInsets(left: 4.0, right: 12.0)
        cellItem.valueConfig = .valueText(row.amountText,
                                          font: .boldSystemFont(ofSize: 16.0),
                                          textColor: .primary)
        cellItem.didSelectHandler = { [weak self] in
            self?.onEditRecord?(row)
        }
        return cellItem
    }
}
