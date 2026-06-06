//
//  TodoTaskMoveInboxSectionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/6.
//

import Foundation


class TodoTaskMoveInboxSectionCellItem: TPImageInfoTableCellItem {
    
    let section: TodoSection
    
    init(section: TodoSection) {
        self.section = section
        super.init()
        self.registerClass = TodoTaskMoveInboxSectionCell.self
        self.contentPadding = UIEdgeInsets(left: 8.0, right: 16.0)
        self.imageName = "todo_section_24"
        self.imageConfig.margins = UIEdgeInsets(right: 4.0)
        self.rightViewSize = .mini
        self.rightViewMargins = UIEdgeInsets(right: 4.0)
        self.height = 50.0
    }
}

class TodoTaskMoveInboxSectionCell: TodoTaskMoveSectionCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TodoTaskMoveInboxSectionCellItem else {
                return
            }

            section = cellItem.section
            depthLineLevels = nil
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
    }
}
    
