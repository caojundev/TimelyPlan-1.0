//
//  TPImageTextFieldTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/4.
//

import Foundation

class TPImageTextFieldTableCellItem: TPTextFieldTableCellItem {
    
    /// 图标名称
    var imageName: String?
    
    /// 图片渲染颜色
    var imageColor: UIColor?
    
    override init() {
        super.init()
        self.registerClass = TPImageTextFieldTableCell.self
        self.leftViewSize = .mini
        self.contentPadding = UIEdgeInsets(left: 5.0, right: 10.0)
        self.leftViewMargins = UIEdgeInsets(value: 5.0)
    }
}

class TPImageTextFieldTableCell: TPTextFieldTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPImageTextFieldTableCellItem else {
                return
            }
            
            if let imageName = cellItem.imageName {
                let image = resGetImage(imageName)
                leftImageView.image = image
            } else {
                leftImageView.image = nil
            }
            
            imageColor = cellItem.imageColor
        }
    }
    
    var imageColor: UIColor? {
        didSet {
            setNeedsLayout()
        }
    }
    
    let leftImageView = UIImageView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.leftView = leftImageView
        self.leftViewSize = .mini
    }
    
    override func layoutLeftView() {
        super.layoutLeftView()
        leftImageView.updateImage(withColor: imageColor)
    }
}
