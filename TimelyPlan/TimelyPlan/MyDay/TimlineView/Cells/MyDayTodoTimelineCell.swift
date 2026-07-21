//
//  MyDayTodoTimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation
import UIKit

class MyDayTodoTimelineCell: TimelineIconCell {
    
    /// 复选信息视图
    private lazy var infoView: MyDayTodoEventInfoView = {
        let view = MyDayTodoEventInfoView()
        view.didClickCheckbox = { [weak self] _ in
            self?.clickCheckbox()
        }
        
        return view
    }()
    
    private var todoItem: TimelineItem?
    
    override func setupEventContentSubviews() {
        eventContentView.addSubview(infoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = eventContentView.bounds
    }
    
    override func configure(with item: TimelineItem) {
        super.configure(with: item)
        self.todoItem = item
        infoView.name = item.title
        infoView.attributedDetail = item.durationText?.attributedString
        infoView.setCompleted(item.isCompleted)
        
        let icon: UIImage?
        if item.isCompleted {
            icon = resGetImage("myDay_todo_completed_24", color: .white)
        } else {
            icon = resGetImage("myDay_todo_normal_24", color: .white)
        }
        
        iconNodeView.configureIcon(icon)
        setNeedsLayout()
    }
    
    func clickCheckbox() {
        
    }
    
}

class MyDayTodoEventInfoView: TodoTaskCheckInfoView {
    
    override func setupSubviews() {
        super.setupSubviews()
        self.leftView = nil
        self.leftViewSize = .zero
        self.leftViewMargins = .zero
        self.rightView = checkbox
        self.rightViewSize = checkboxSize
        self.rightViewMargins = UIEdgeInsets(left: 12.0)
    }
    
}

