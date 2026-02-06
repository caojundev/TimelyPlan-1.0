//
//  TPTableItemSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/27.
//

import Foundation
import UIKit

class TPTableItemSectionController: TPTableBaseSectionController,
                                        TPTextViewTableCellDelegate {

    lazy var headerItem: TPDefaultInfoTableHeaderFooterItem = {
        let item = TPDefaultInfoTableHeaderFooterItem()
        item.height = 0.0
        return item
    }()
    
    lazy var footerItem: TPDefaultInfoTableHeaderFooterItem = {
        let item = TPDefaultInfoTableHeaderFooterItem()
        item.height = 0.0
        return item
    }()
    
    var cellItems: [TPBaseTableCellItem]?
    
    override var items: [ListDiffable]? {
        return cellItems
    }
    
    override func shouldHighlightRow(at index: Int) -> Bool {
        let cellItem = item(at: index) as! TPBaseTableCellItem
        return !cellItem.isDisabled
    }

    override func classForCell(at index: Int) -> AnyClass? {
        let cellItem = item(at: index) as! TPBaseTableCellItem
        return cellItem.registerClass
    }

    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? TPBaseTableCell else {
            return
        }
        
        let cellItem = item(at: index) as! TPBaseTableCellItem
        cellItem.updater?()
        /// 设置单元格条目
        cell.cellItem = cellItem
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        let cellItem = item(at: index) as! TPBaseTableCellItem
        cellItem.updater?()
        cellItem.cellWidth = adapter?.tableViewCellWidth()
        return cellItem.height
    }
    
    override func styleForRow(at index: Int) -> TPTableCellStyle? {
        let cellItem = item(at: index) as! TPBaseTableCellItem
        if let style = cellItem.style {
            return style
        }
        
        return adapter?.cellStyle
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        if let cellItem = item(at: index) as? TPBaseTableCellItem {
            return cellItem.isChecked
        }

        return false
    }
    
    override func didSelectRow(at index: Int) {
        super.didSelectRow(at: index)
        let cellItem = item(at: index) as! TPBaseTableCellItem
        if cellItem.isDisabled || cellItem.selectionStyle == .none {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        cellItem.didSelectHandler?()
    }

    
    // MARK: - Header
    override func heightForHeader() -> CGFloat {
        return headerItem.height
    }
    
    override func classForHeader() -> AnyClass? {
        return headerItem.registerClass
    }
    
    override func didDequeHeader(_ headerView: UITableViewHeaderFooterView) {
        if let headerView = headerView as? TPBaseTableHeaderFooterView {
            headerView.headerFooterItem = headerItem
            headerView.delegate = self
        }
    }
    
    // MARK: - Footer
    func setupSeparatorFooterItem(lineHeight: CGFloat = 1.0,
                                  lineColor: UIColor = Color(0x888888, 0.1),
                                  backgroundColor: UIColor = .clear) {
        let footerItem = TPSeparatorTableHeaderFooterItem()
        footerItem.height = 1.0
        footerItem.lineHeight = lineHeight
        footerItem.lineColor = lineColor
        footerItem.backgroundColor = backgroundColor
        self.footerItem = footerItem
    }
    
    override func heightForFooter() -> CGFloat {
        return footerItem.height
    }

    override func classForFooter() -> AnyClass? {
        return footerItem.registerClass
    }
    
    override func didDequeFooter(_ footerView: UITableViewHeaderFooterView) {
        if let footerView = footerView as? TPBaseTableHeaderFooterView {
            footerView.delegate = self
            footerView.headerFooterItem = footerItem
        }
    }

    // MARK: - TPTextViewTableCellDelegate
    /// 文本编辑改变，更新单元格高度
    func textViewTableCell(_ cell: TPTextViewTableCell, editingChanged textView: UITextView) {
        updateText(textView.text, forTextViewTableViewCell: cell)
    }
    
    /// 更新textView单元格文本
    func updateText(_ text: String?, forTextViewTableViewCell cell: TPTextViewTableCell) {
        guard let oldCellItem = cell.cellItem,
              let newCellItem = adapter?.item(of: oldCellItem) as? TPAutoResizeTextViewTableCellItem else {
            return
        }
        
        newCellItem.text = text
        if cell.textView.text != text {
            cell.textView.text = text
        }
        
        if newCellItem.textViewHeight != cell.textView.height {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            adapter?.performNilUpdate()
            CATransaction.commit()
        }
    }
}
