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
    func todoSmartListCell(_ cell: TodoSmartListCell, requestCount completion: @escaping (Int?) -> Void)
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
        self.padding = UIEdgeInsets(right: 32.0)
        self.contentPadding = UIEdgeInsets(left: 16.0, right: 0.0)
        self.imageConfig.margins = UIEdgeInsets(right: 8.0)
        self.imageConfig.shouldRenderImageWithColor = false
    }
    
    func updateListInfo() {
        self.infoView.title = list?.title
        self.imageContent = .withName(list?.iconName)
        self.updateTaskCount()
        setNeedsLayout()
    }
    
    /// 更新任务数目
    func updateTaskCount() {
        guard let list = self.list, let delegate = delegate as? TodoSmartListCellDelegate else {
            self.valueConfig = nil
            setNeedsLayout()
            return
        }
        
        let identifier = list.identifier
        delegate.todoSmartListCell(self) { [weak self] count in
            guard let self = self, identifier == self.list?.identifier else {
                return
            }
            
            if let count = count, count > 0 {
                self.valueConfig = .valueText("\(count)")
            } else {
                self.valueConfig = nil
            }
        }
        
        setNeedsLayout()
    }
}
