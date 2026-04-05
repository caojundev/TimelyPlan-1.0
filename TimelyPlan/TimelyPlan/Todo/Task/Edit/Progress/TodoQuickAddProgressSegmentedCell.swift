//
//  TodoQuickAddProgressSegmentedCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/4.
//

import Foundation

class TodoQuickAddProgressSegmentedCellItem: TPFullSizeSegmentedMenuTableCellItem {
    
    override init() {
        super.init()
        self.selectionStyle = .none
        self.registerClass = TodoQuickAddProgressSegmentedCell.self
        self.imageConfig.margins = UIEdgeInsets(left: 4.0, right: 4.0)
        self.titleConfig.font = SMALL_SYSTEM_FONT
        self.contentPadding = UIEdgeInsets(horizontal: 8.0, vertical: 8.0)
        self.backgroundColor = .primary.withAlphaComponent(0.2)
        self.cornerRadius = .greatestFiniteMagnitude
        self.menuPadding = UIEdgeInsets(value: 2.0)
        self.height = 84.0
    }
}

class TodoQuickAddProgressSegmentedCell: TPFullSizeSegmentedMenuTableCell {
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = contentView.layoutFrame()
        infoView.padding = UIEdgeInsets(left: 8.0, right: 8.0)
        infoView.width = layoutFrame.width
        infoView.height = 20.0
        infoView.origin = layoutFrame.origin
        
        menuView.width = layoutFrame.width
        menuView.height = 40.0
        menuView.bottom = layoutFrame.maxY
        menuView.left = layoutFrame.minX
    }
}
