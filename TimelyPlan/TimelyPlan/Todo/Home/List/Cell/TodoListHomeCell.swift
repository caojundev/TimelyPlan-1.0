//
//  TodoListHomeCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/1.
//

import Foundation
import UIKit

protocol TodoListHomeCellDelegate: AnyObject {
    
    /// 点击更多按钮
    func todoListHomeCellDidClickMore(_ cell: TodoListHomeCell)
}

class TodoListHomeCell: TodoListBaseCell {
    
    override var list: TodoList? {
        didSet {
            updateTaskCount()
            setNeedsLayout()
        }
    }

    /// 更多按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.imageConfig.color = .secondaryLabel
        button.addTarget(self, action: #selector(clickMore(_:)), for: .touchUpInside)
        return button
    }()

    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.rightView = moreButton
        self.rightViewSize = .mini
    }
    
    // MARK: - Update
    func updateTaskCount() {
        var taskCount = 0
        if let list = list {
            taskCount = todo.numberOfTasks(in: list)
        }
        
        let valueText = taskCount > 0 ? "\(taskCount)" : nil
        iconInfoTextValueView.valueConfig = .valueText(valueText)
    }
    
    // MARK: - Event Response
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        if let delegate = delegate as? TodoListHomeCellDelegate {
            delegate.todoListHomeCellDidClickMore(self)
        }
    }
    
}
