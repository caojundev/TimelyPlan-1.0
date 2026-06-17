//
//  TPPermissionDeniedTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/17.
//

import Foundation
import UIKit

class TPPermissionDeniedTableCellItem: TPBaseTableCellItem {
    
    var title: String?
    
    var subtitle: String?
    
    var imageName: String?
    
    var backgroundColor = UIColor.secondarySystemGroupedBackground
    
    override init() {
        super.init()
        self.registerClass = TPPermissionDeniedTableCell.self
        self.selectionStyle = .none
        self.height = 360.0
        self.style = TPTableCellStyle()
        self.style?.backgroundColor = .clear
    }
}

class TPPermissionDeniedTableCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPPermissionDeniedTableCellItem else {
                return
            }

            deniedView.titleLabel.text = cellItem.title
            deniedView.subtitleLabel.text = cellItem.subtitle
            if let imageName = cellItem.imageName {
                deniedView.imageView.image = resGetImage(imageName)
            }
            
            deniedView.backgroundColor = cellItem.backgroundColor
            setNeedsLayout()
        }
    }
    
    let deniedView = TPPermissionDeniedView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        deniedView.clipsToBounds = true
        contentView.addSubview(deniedView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        deniedView.width = contentView.width
        deniedView.sizeToFit()
        deniedView.top = layoutFrame.minY
    }
}
