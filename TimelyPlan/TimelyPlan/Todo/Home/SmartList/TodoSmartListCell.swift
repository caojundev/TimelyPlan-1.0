//
//  TodoSmartListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/7.
//

import Foundation
import UIKit

protocol TodoSmartListCellDelegate: AnyObject {

    /// 获取单元格待办数量
    func countForTodoSmartListCell(_ cell: TodoSmartListCell) -> Int
}

class TodoSmartListCell: TPImageInfoTextValueTableCell {
    
    var list: TodoSmartList? {
        didSet {
            self.updateListInfo()
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.accessoryType = .disclosureIndicator
        self.titleConfig.font = .boldSystemFont(ofSize: 15.0)
        self.padding = UIEdgeInsets(right: 32.0)
        self.contentPadding = UIEdgeInsets(left: 16.0, right: 4.0)
        self.imageConfig.margins = UIEdgeInsets(right: 8.0)
        self.imageConfig.shouldRenderImageWithColor = true
    }
    
    func updateListInfo() {
        if let list = list {
            self.infoView.title = list.title
            self.imageConfig.color = list.color
            self.imageContent = .withName(list.iconName)
            self.updateTaskCount()
        }
        
        setNeedsLayout()
    }
    
    /// 更新任务数目
    func updateTaskCount() {
        guard let delegate = delegate as? TodoSmartListCellDelegate else {
            self.valueConfig = nil
            setNeedsLayout()
            return
        }
        
        let count = delegate.countForTodoSmartListCell(self)
        if count > 0 {
            self.valueConfig = .valueText("\(count)", font: SYSTEM_FONT)
        } else {
            self.valueConfig = nil
        }
        
        setNeedsLayout()
    }
}
