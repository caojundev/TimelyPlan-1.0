//
//  TodoSmartListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/7.
//

import Foundation
import UIKit

class TodoSmartListCell: TPImageInfoTextValueTableCell {
    
    var list: TodoSmartList? {
        didSet {
            self.infoView.title = list?.title
            self.imageContent = .withName(list?.iconName)
            self.valueConfig = .valueText("12")
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.accessoryType = .disclosureIndicator
        self.padding = UIEdgeInsets(right: 32.0)
        self.contentPadding = UIEdgeInsets(left: 16.0, right: 0.0)
        self.imageConfig.margins = UIEdgeInsets(right: 8.0)
        self.imageConfig.shouldRenderImageWithColor = false
    }
    
}
