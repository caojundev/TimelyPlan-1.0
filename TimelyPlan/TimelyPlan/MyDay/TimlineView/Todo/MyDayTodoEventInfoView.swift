//
//  MyDayTodoEventInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/1.
//

import Foundation

class MyDayTodoEventInfoView: TodoTaskCheckInfoView {
    
    override var priority: TodoTaskPriority {
        didSet {
            if isDetached {
                repeatButton.imageConfig.color = priority.titleColor
            }
        }
    }
    
    var isDetached: Bool = false {
        didSet {
            if isDetached {
                repeatButton.imageConfig.color = priority.titleColor
                rightView = repeatButton
            } else {
                rightView = checkbox
            }
        }
    }
    
    /// 重复按钮
    lazy var repeatButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.image = resGetImage("myDay_todo_repeat_24")
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        self.leftView = nil
        self.leftViewSize = .zero
        self.leftViewMargins = .zero
        self.rightView = checkbox
        self.rightViewSize = checkboxSize
        self.rightViewMargins = UIEdgeInsets(left: 12.0)
        self.nameLabel.font = MyDayTimelineConfig.titleFont
        self.detailLabel.font = MyDayTimelineConfig.todoDetailFont
        self.detailLabel.numberOfLines = 2
        self.detailTopMargin = 2.0
        self.detailHeight = 24.0
        self.progressTopMargin = 6.0
    }
    
}
