//
//  TodoHomeExpandSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/23.
//

import Foundation

class TodoHomeHeaderSectionController: TPTableItemSectionController,
                                       TodoHomeHeaderTableCellDelegate {
    
    /// 点击添加
    var didClickAdd: (() -> Void)?
    
    var didToggleExpanded: ((Bool) -> Void)?
    
    lazy var cellItem: TodoHomeHeaderTableCellItem = {
        let cellItem = TodoHomeHeaderTableCellItem()
        return cellItem
    }()
    
    let sectionType: TodoHomeSectionType
    
    init(sectionType: TodoHomeSectionType) {
        self.sectionType = sectionType
        super.init()
        self.cellItem.title = sectionType.title
        self.cellItem.imageName = sectionType.iconName
        self.cellItem.imageConfig.color = sectionType.iconColor
        self.cellItems = [cellItem]
        self.headerItem = separatorHeaderFooterItem(lineHeight: 0.8,
                                                    lineColor: Color(0x888888, 0.1),
                                                    backgroundColor: .systemBackground)
    }
    
    func setExpanded(_ isExpanded: Bool) {
        self.cellItem.isExpanded = isExpanded
        if let cell = adapter?.cellForItem(cellItem) as? TodoHomeHeaderTableCell {
            cell.setExpanded(isExpanded, animated: true)
        }
    }
    
    override func didSelectRow(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        guard let cell = cellForRow(at: index) as? TodoHomeHeaderTableCell else {
            return
        }
        
        cell.toggleExpand()
        let isExpanded = cell.isExpanded
        cellItem.isExpanded = isExpanded
        didToggleExpanded?(isExpanded)
    }
    
    // MARK: - TodoHomeHeaderTableCellDelegate
    func todoHomeHeaderTableCellDidClickAdd(_ cell: TodoHomeHeaderTableCell) {
        didClickAdd?()
    }
}
