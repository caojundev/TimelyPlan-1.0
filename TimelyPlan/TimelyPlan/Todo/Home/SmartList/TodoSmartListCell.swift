//
//  TodoSmartListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/7.
//

import Foundation
import UIKit

class TodoSmartListCell: TPImageInfoTextValueTableCell {
    
    var list: TodoSmartList? {
        didSet {
            infoView.title = list?.title
            imageContent = .withName(list?.iconName)
            
            /// 任务数目
            let valueConfig = TPTextAccessoryConfig()
            var taskCount: Int = 0
            if let list = list {
                taskCount = todo.numberOfTasks(in: list)
            }
            
            if taskCount > 0 {
                valueConfig.valueText = "\(taskCount)"
            } else {
                valueConfig.valueText = nil
            }
            
            self.valueConfig = valueConfig
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        accessoryType = .disclosureIndicator
        padding = UIEdgeInsets(right: 32.0)
        contentPadding = UIEdgeInsets(left: 25.0, right: 0.0)
        imageConfig.margins = UIEdgeInsets(right: 4.0)
        imageConfig.shouldRenderImageWithColor = false
    }
    
}
