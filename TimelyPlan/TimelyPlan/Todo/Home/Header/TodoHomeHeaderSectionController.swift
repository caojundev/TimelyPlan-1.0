//
//  TodoHomeExpandSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/23.
//

import Foundation

enum TodoHomeHeaderSectionType: String, TPMenuRepresentable {
    case list
    case tag
    case filter
    
    var title: String {
        switch self {
        case .list:
            return resGetString("List")
        case .tag:
            return resGetString("Tag")
        case .filter:
            return resGetString("Filter")
        }
    }
    
    var iconName: String? {
        switch self {
        case .list:
            return "todo_list_24"
        case .tag:
            return "todo_home_tag_24"
        case .filter:
            return "todo_home_filter_24"
        }
    }
    
    var iconColor: UIColor {
        switch self {
        case .list:
            return .primary
        case .tag:
            return .orangePrimary
        case .filter:
            return .purplePrimary
        }
    }
}

class TodoHomeHeaderSectionController: TPTableItemSectionController,
                                       TodoHomeHeaderTableCellDelegate {
    
    /// 点击添加
    var didClickAdd: (() -> Void)?
    
    var didToggleExpanded: ((Bool) -> Void)?
    
    lazy var cellItem: TodoHomeHeaderTableCellItem = {
        let cellItem = TodoHomeHeaderTableCellItem()
        return cellItem
    }()
    
    let sectionType: TodoHomeHeaderSectionType
    
    init(sectionType: TodoHomeHeaderSectionType) {
        self.sectionType = sectionType
        super.init()
        self.cellItem.title = sectionType.title
        self.cellItem.imageName = sectionType.iconName
        self.cellItem.imageConfig.color = sectionType.iconColor
        self.cellItems = [cellItem]
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
