//
//  TPPlaceholderTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/25.
//

import Foundation

class TFPlaceholderTableCellItem: TPBaseTableCellItem {
    
    var placeholderTitle: String?
    
    override init() {
        super.init()
        self.registerClass = TPPlaceholderTableCell.self
        self.selectionStyle = .none
        self.height = 120.0
    }
}

class TPPlaceholderTableCell: TPBaseTableCell {
    
    var placeholderView: TPDefaultPlaceholderView!
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TFPlaceholderTableCellItem else {
                return
            }
            
            placeholderView.padding = UIEdgeInsets(value: 5.0)
            placeholderView.isBorderHidden = false
            placeholderView.title = cellItem.placeholderTitle
            placeholderView.titleLabel.font = BOLD_SYSTEM_FONT
            placeholderView.titleLabel.alpha = 0.6
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        placeholderView = TPDefaultPlaceholderView(frame: bounds)
        contentView.addSubview(placeholderView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderView.frame = bounds
    }
}
