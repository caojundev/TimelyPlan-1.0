//
//  TPDefaultInfoColorValueTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/14.
//

import Foundation
import UIKit

class TPDefaultInfoColorValueTableCellItem: TPDefaultInfoTableCellItem {
    
    var color: UIColor?
    
    override init() {
        super.init()
        self.accessoryType = .disclosureIndicator
        self.contentPadding = UIEdgeInsets(left: 16.0)
        self.registerClass = TPDefaultInfoColorValueTableCell.self
        self.rightViewSize = .size(4)
        self.rightViewMargins = UIEdgeInsets(left: 5.0, right: 5.0)
    }
}

class TPDefaultInfoColorValueTableCell: TPDefaultInfoTableCell {
   
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            let cellItem = cellItem as? TPDefaultInfoColorValueTableCellItem
            colorView.backgroundColor = cellItem?.color ?? .clear
        }
    }
    
    var color: UIColor? {
        get {
            return colorView.backgroundColor
        }
        
        set {
            colorView.backgroundColor = newValue
        }
    }
    
    private let colorView = UIView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.rightView = colorView
        self.rightViewSize = .size(4)
        self.rightViewMargins = UIEdgeInsets(left: 5.0, right: 5.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorView.layer.cornerRadius = rightViewSize.height / 2.0
    }
}
