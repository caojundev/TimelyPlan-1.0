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

    override init() {
        super.init()
        self.registerClass = TPPermissionDeniedTableCell.self
        self.selectionStyle = .none
        self.height = 360.0
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
        deniedView.frame = contentView.bounds
    }
}
