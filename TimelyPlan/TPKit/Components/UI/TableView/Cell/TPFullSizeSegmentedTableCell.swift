//
//  TPFullSizeSegmentedTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/30.
//

import Foundation
import UIKit

class TPFullSizeSegmentedMenuTableCellItem: TPSegmentedMenuTableCellItem {
    
    override init() {
        super.init()
        self.registerClass = TPFullSizeSegmentedMenuTableCell.self
        self.contentPadding = .zero
        self.backgroundColor = .clear
    }
}

class TPFullSizeSegmentedMenuTableCell: TPSegmentedMenuTableCell {
    
    override func setupSegmentedMenuView() {
        self.contentView.addSubview(menuView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.menuView.frame = contentView.layoutFrame()
    }
}
