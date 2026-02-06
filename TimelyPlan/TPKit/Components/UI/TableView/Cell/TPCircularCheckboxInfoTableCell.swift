//
//  TPCircularCheckboxInfoTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/14.
//

import Foundation
import UIKit

class TPCircularCheckboxInfoTableCellItem: TPDefaultInfoTableCellItem {
    
    override init() {
        super.init()
        self.contentPadding = UIEdgeInsets(horizontal: 16.0)
        self.registerClass = TPCircularCheckboxInfoTableCell.self
        self.leftViewSize = .size(4)
        self.leftViewMargins = UIEdgeInsets(left: 5.0, right: 15.0)
    }
}

class TPCircularCheckboxInfoTableCell: TPDefaultInfoTableCell {
   
    private lazy var checkbox: TPCircularCheckbox = {
        let checkbox = TPCircularCheckbox()
        checkbox.isUserInteractionEnabled = false
        checkbox.outerLineWidth = 1.8
        return checkbox
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.leftView = checkbox
        self.leftViewSize = .size(4)
        self.leftViewMargins = UIEdgeInsets(left: 5.0, right: 15.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCheckboxStyle()
    }
    
    func updateCheckboxStyle() {
        checkbox.alpha = isChecked ? 1.0 : 0.4
        if isChecked {
            checkbox.innerColor = .primary
        } else {
            checkbox.innerColor = resGetColor(.title)
        }
        
        checkbox.outerColor = checkbox.innerColor
    }
  
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkbox.setChecked(checked, animated: animated)
        updateCheckboxStyle()
    }
}
