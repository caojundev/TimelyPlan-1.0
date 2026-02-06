//
//  TPImageInfoTextValueTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/7.
//

import Foundation
import UIKit

class TPImageInfoTextValueTableCellItem: TPImageInfoTableCellItem {

    /// 值配置
    var valueConfig = TPTextAccessoryConfig()
    
    override init() {
        super.init()
        self.registerClass = TPImageInfoTextValueTableCell.self
        self.contentPadding = TableCellLayout.withAccessoryContentPadding
    }
    
    override func getLayout() -> TPBaseTableCellLayout {
        let layout = super.getLayout() as! TPDefaultInfoTableCellLayout
        layout.rightAccessorySize = valueConfig.valueSize
        layout.rightAccessoryMargins = valueConfig.valueMargins
        return layout
    }
}

class TPImageInfoTextValueTableCell: TPImageInfoTableCell {
    
    /// 值配置
    var valueConfig: TPTextAccessoryConfig? {
        didSet {
            guard let infoView = infoView as? TPImageInfoTextValueView else {
                return
            }
            
            infoView.valueConfig = valueConfig
            setNeedsLayout()
        }
    }
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPImageInfoTextValueTableCellItem else {
                return
            }
            
            valueConfig = cellItem.valueConfig
            setNeedsLayout()
        }
    }
    
    override func setupInfoView() {
        self.infoView = TPImageInfoTextValueView()
    }
}
