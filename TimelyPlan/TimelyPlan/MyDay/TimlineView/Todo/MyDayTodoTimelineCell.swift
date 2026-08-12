//
//  MyDayTodoTimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation
import UIKit

class MyDayTodoTimelineCell: TimelineIconCell {
        
    private let infoViewHeight = 60.0
    
    /// 复选信息视图
    private lazy var infoView: MyDayTodoEventInfoView = {
        let view = MyDayTodoEventInfoView()
        view.didClickCheckbox = { [weak self] _ in
            self?.clickCheckbox()
        }
        
        return view
    }()
    
    private var todoItem: TimelineItem?
    private var todoTask: TodoTask?
    
    override func setupEventContentSubviews() {
        eventContentView.addSubview(infoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = eventContentView.bounds
    }
    
    override func eventContentHeight() -> CGFloat {
        return infoViewHeight
    }
    
    let detailOption: TodoTaskDetailOption = [.schedule,
                                              .step,
                                              .progress,
                                              .tag,
                                              .list,
                                              .note]
    
    override func configure(with item: TimelineItem) {
        super.configure(with: item)
        self.todoItem = item
        self.todoTask = item.event.sourceItem as? TodoTask
        
        guard let task = self.todoTask else {
            return
        }
        
        configureIcon(with: task)
        infoView.isDetached = task.isDetached
        infoView.checkType = task.checkType
        infoView.priority = task.priority
        infoView.name = task.displayName
        
        /// 更新详情
        let detailProvider = TodoTaskDetailProvider(task: task, option: detailOption)
        infoView.attributedDetail = detailProvider.attributedInfo()
        
        /// 更新进度
        infoView.isProgressHidden = !task.isProgressSet
        infoView.setProgress(task.completionFraction)
        
        /// 完成状态
        infoView.setCompleted(task.isCompleted)
        
        setNeedsLayout()
    }
    
    /// 更新图标
    private func configureIcon(with task: TodoTask) {
        let icon: UIImage?
        if task.isCompleted {
            icon = resGetImage("myDay_todo_completed_24", color: .white)
        } else {
            icon = resGetImage("myDay_todo_normal_24", color: .white)
        }
        
        iconNodeView.configureIcon(icon)
    }
    
    func clickCheckbox() {
        guard let task = self.todoTask else {
            return
        }
        
        let taskController = TodoTaskController()
        taskController.clickCheckbox(for: task) { isCompleted, execution in
            self.infoView.setCompleted(isCompleted, animated: true) {
                execution?()
            }
        } progressHandler: { progress, execution in
            self.infoView.setProgress(progress.completionFraction, animated: true) {
                execution?()
            }
        }
    }
}
