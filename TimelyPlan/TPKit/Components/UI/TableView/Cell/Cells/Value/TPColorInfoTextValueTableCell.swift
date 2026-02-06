//
//  TPColorInfoTextValueTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/5.
//

import Foundation

class TPColorInfoTextValueTableCellItem: TPDefaultInfoTextValueTableCellItem {

    /// 颜色配置
    var colorConfig = TPColorAccessoryConfig()
    
    override init() {
        super.init()
        self.registerClass = TPColorInfoTextValueTableCell.self
        self.contentPadding = UIEdgeInsets(left: 15.0, right: 5.0)
    }
    
    override func getLayout() -> TPBaseTableCellLayout {
        let layout = super.getLayout() as! TPDefaultInfoTableCellLayout
        layout.leftAccessorySize = colorConfig.size
        layout.leftAccessoryMargins = colorConfig.margins
        return layout
    }
}

class TPColorInfoTextValueTableCell: TPDefaultInfoTextValueTableCell {
    
    /// 颜色配置
    var colorConfig: TPColorAccessoryConfig? {
        didSet {
            guard let infoView = infoView as? TPColorInfoTextValueView else {
                return
            }
            
            infoView.colorConfig = colorConfig
            setNeedsLayout()
        }
    }
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPColorInfoTextValueTableCellItem else {
                return
            }

            colorConfig = cellItem.colorConfig
            setNeedsLayout()
        }
    }
    
    override func setupInfoView() {
        self.infoView = TPColorInfoTextValueView()
    }
}
