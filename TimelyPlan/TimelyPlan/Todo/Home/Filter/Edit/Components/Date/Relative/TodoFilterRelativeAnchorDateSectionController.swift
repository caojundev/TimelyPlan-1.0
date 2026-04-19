//
//  TodoFilterRelativeAnchorDateSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/15.
//

import Foundation

class TodoFilterRelativeAnchorDateSectionController: TPTableItemSectionController {
    
    /// 锚点日期改变
    var didChangeAnchorDate: ((TodoRelativeAnchorDate) -> Void)?
    
    lazy var dateCellItem: TPDefaultInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPDefaultInfoTextValueTableCellItem()
        cellItem.contentPadding = TableCellLayout.withoutAccessoryContentPadding
        cellItem.height = 50.0
        cellItem.title = resGetString("Anchor Date")
        cellItem.selectionStyle = .none
        cellItem.updater = {
            self?.updateDateCellItem()
        }
        
        return cellItem
    }()
    
    lazy var offsetCellItem: TimeOffsetPickerViewCellItem = { [weak self] in
        let cellItem = TimeOffsetPickerViewCellItem()
        cellItem.updater = {
            self?.updateOffsetCellItem()
        }

        cellItem.didChangeTimeOffset = { timeOffset in
            self?.changeTimeOffset(timeOffset)
        }
        
        return cellItem
    }()
    
    private(set) var anchorDate: TodoRelativeAnchorDate
    
    init(anchorDate: TodoRelativeAnchorDate?) {
        self.anchorDate = anchorDate ?? TodoRelativeAnchorDate()
        super.init()
        self.headerItem.height = 10.0
        self.footerItem.height = 0.0
        self.cellItems = [dateCellItem,
                          offsetCellItem]
    }

    // MARK: - Update CellItems
    func updateDateCellItem() {
        let valueText = anchorDate.description
        dateCellItem.valueConfig = .valueText(valueText, textColor: .primary)
    }
    
    func updateOffsetCellItem() {
        offsetCellItem.timeOffset = anchorDate.offset ?? TimeOffset()
    }
    
    func changeTimeOffset(_ offset: TimeOffset) {
        if anchorDate.offset != offset {
            anchorDate.offset = offset
            adapter?.reloadCell(forItem: dateCellItem, with: .none)
            didChangeAnchorDate?(anchorDate)
        }
    }
}
