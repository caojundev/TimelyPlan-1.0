//
//  CalendarEventPreviewInfoCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/14.
//

import Foundation
import UIKit

class CalendarEventPreviewInfoCellItem: TPBaseTableCellItem {
    
    var event: CalendarEventPreviewDisplayable?
    
    override init() {
        super.init()
        self.registerClass = CalendarEventPreviewInfoCell.self
        self.height = CalendarEventPreviewInfoView.contentHeight
    }
}

class CalendarEventPreviewInfoCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? CalendarEventPreviewInfoCellItem else {
                return
            }
            
            infoView.event = cellItem.event
        }
    }
    
    private let infoView = CalendarEventPreviewInfoView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(infoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = bounds
    }
}
