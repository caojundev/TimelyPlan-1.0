//
//  TPImageInfoCircularCheckboxTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/19.
//

import Foundation

class TPImageInfoCircularCheckboxTableCellItem: TPImageInfoTableCellItem {
    
    override init() {
        super.init()
        self.registerClass = TPImageInfoCircularCheckboxTableCell.self
        self.rightViewSize = .size(4)
    }
}

class TPImageInfoCircularCheckboxTableCell: TPImageInfoTableCell {
   
    private lazy var checkbox: TPCircularCheckbox = {
        let checkbox = TPCircularCheckbox()
        checkbox.isUserInteractionEnabled = false
        checkbox.outerLineWidth = 1.8
        return checkbox
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.rightView = checkbox
        self.rightViewSize = .size(4)
        self.rightViewMargins = UIEdgeInsets(left: 5.0, right: 5.0)
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
