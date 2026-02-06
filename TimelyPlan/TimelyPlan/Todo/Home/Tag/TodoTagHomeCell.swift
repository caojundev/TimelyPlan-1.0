//
//  TodoTagHomeCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/29.
//

import Foundation

protocol TodoTagHomeCellDelegate: AnyObject {
    
    /// 点击更多
    func todoTagHomeCellDidClickMore(_ cell: TodoTagHomeCell)
}

class TodoTagHomeCell: TPColorInfoTextValueTableCell {
    
    var userTag: TodoTag? {
        didSet {
            infoView.title = userTag?.name ?? resGetString("Untitled")

            let colorConfig = TPColorAccessoryConfig()
            colorConfig.color = userTag?.color ?? TodoTag.defaultColor
            self.colorConfig = colorConfig

            let valueConfig = TPTextAccessoryConfig()
            var taskCount: Int = 0
            if let userTag = userTag {
                taskCount = todo.taskCount(for: userTag)
            }
            
            if taskCount > 0 {
                valueConfig.valueText = "\(taskCount)"
            } else {
                valueConfig.valueText = nil
            }
            
            self.valueConfig = valueConfig
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
        rightView = moreButton
        rightViewSize = .mini
    }
    
    // MARK: - Event Response
    /// 点击更多
    func clickMore() {
        if let delegate = delegate as? TodoTagHomeCellDelegate {
            delegate.todoTagHomeCellDidClickMore(self)
        }
    }
    
}
