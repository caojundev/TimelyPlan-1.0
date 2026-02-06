//
//  TPDefaultInfoTextValueTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/5.
//

import Foundation
import UIKit

class TPDefaultInfoTextValueTableCellItem: TPDefaultInfoTableCellItem {

    /// 值配置
    var valueConfig = TPTextAccessoryConfig()
    
    override init() {
        super.init()
        self.registerClass = TPDefaultInfoTextValueTableCell.self
        self.contentPadding = UIEdgeInsets(left: 15.0, right: 5.0)
    }
    
    override func getLayout() -> TPBaseTableCellLayout {
        let layout = super.getLayout() as! TPDefaultInfoTableCellLayout
        layout.rightAccessorySize = valueConfig.valueSize
        layout.rightAccessoryMargins = valueConfig.valueMargins
        return layout
    }
}

class TPDefaultInfoTextValueTableCell: TPDefaultInfoTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            updateValueConfig()
        }
    }
    
    var valueConfig: TPTextAccessoryConfig? {
        didSet {
            guard let infoView = infoView as? TPInfoTextValueView else {
                return
            }
            
            infoView.valueConfig = valueConfig
            setNeedsLayout()
        }
    }
    
    override func setupInfoView() {
        self.infoView = TPInfoTextValueView()
    }
    
    func updateValueConfig() {
        guard let cellItem = cellItem as? TPDefaultInfoTextValueTableCellItem else {
            return
        }

        valueConfig = cellItem.valueConfig
        setNeedsLayout()
    }
}
