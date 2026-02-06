//
//  TPIconInfoTextValueTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/6.
//

import Foundation

class TPIconInfoTextValueTableCellItem: TPDefaultInfoTextValueTableCellItem {

    /// 图标配置
    var iconConfig = TPIconAccessoryConfig()
    
    override init() {
        super.init()
        self.registerClass = TPIconInfoTextValueTableCell.self
        self.contentPadding = UIEdgeInsets(left: 15.0, right: 5.0)
    }
    
    override func getLayout() -> TPBaseTableCellLayout {
        let layout = super.getLayout() as! TPDefaultInfoTableCellLayout
        layout.leftAccessorySize = iconConfig.size
        layout.leftAccessoryMargins = iconConfig.margins
        return layout
    }
}

class TPIconInfoTextValueTableCell: TPDefaultInfoTextValueTableCell {
    
    var iconConfig: TPIconAccessoryConfig? {
        didSet {
            guard let infoView = infoView as? TPIconInfoTextValueView else {
                return
            }
            
            infoView.iconConfig = iconConfig
            setNeedsLayout()
        }
    }
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPIconInfoTextValueTableCellItem else {
                return
            }

            iconConfig = cellItem.iconConfig
            setNeedsLayout()
        }
    }
    
    override func setupInfoView() {
        self.infoView = TPIconInfoTextValueView()
    }
}
