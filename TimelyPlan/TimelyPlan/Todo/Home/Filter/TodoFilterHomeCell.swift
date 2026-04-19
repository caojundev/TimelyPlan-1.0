//
//  TodoFilterHomeCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/16.
//

import Foundation
import UIKit

protocol TodoFilterCellDelegate: AnyObject {
    
    /// 点击更多
    func todoFilterCellDidClickMore(_ cell: TodoFilterCell)
    
    /// 获取单元格待办数量
    func todoFilterCell(_ cell: TodoFilterCell, requestCount completion: @escaping (Int?) -> Void)
}

class TodoFilterCell: TPColorInfoTextValueTableCell {

    let colorSize = CGSize(width: 4.0, height: 16.0)
    
    var filter: TodoFilter? {
        didSet {
            updateFilterInfo()
        }
    }
    
    /// 更多按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.didClickHandler = { [weak self] in
            self?.clickMore()
        }
        
        return button
    }()

    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.contentPadding = UIEdgeInsets(left: 6.0, right: 12.0)
        self.rightView = moreButton
        self.rightViewSize = .mini
    }
    
    // MARK: - Update
    func updateFilterInfo() {
        let colorConfig = TPColorAccessoryConfig()
        colorConfig.size = colorSize
        colorConfig.color = filter?.color ?? TodoFilter.defaultColor
        self.colorConfig = colorConfig
        self.infoView.title = filter?.name ?? resGetString("Untitled")
        self.updateTaskCount()
        setNeedsLayout()
    }
    
    /// 更新任务数目
    func updateTaskCount() {
        guard let filter = self.filter, let delegate = delegate as? TodoFilterCellDelegate else {
            self.valueConfig = nil
            setNeedsLayout()
            return
        }
        
        let identifier = filter.identifier
        delegate.todoFilterCell(self) { [weak self] count in
            guard let self = self, identifier == self.filter?.identifier else {
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
    
    // MARK: - Event Response
    /// 点击更多
    func clickMore() {
        if let delegate = delegate as? TodoFilterCellDelegate {
            delegate.todoFilterCellDidClickMore(self)
        }
    }
    
}
