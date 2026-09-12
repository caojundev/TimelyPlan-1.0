//
//  MyDayGoalTimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/12.
//

import Foundation
import UIKit

class MyDayGoalTimelineCell: TimelineIconCell {
    
    private let infoViewHeight = 60.0
    
    /// 复选信息视图
    private lazy var infoView: MyDayGoalEventInfoView = {
        let view = MyDayGoalEventInfoView()
        view.didClickCheckbox = { [weak self] _ in
            self?.clickCheckbox()
        }
        
        return view
    }()
    
    private var goalTask: GoalTask?
    
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
    
    override func configure(with item: TimelineItem) {
        super.configure(with: item)
        self.goalTask = item.event.sourceItem as? GoalTask
        
        guard let task = self.goalTask else {
            return
        }
        
        configureIcon(with: item, task: task)
        
        /// 更新名称、进度与完成状态
        infoView.updateContent(with: task, animated: false)
        
        /// 更新详情
        let detailProvider = GoalTaskDetailProvider(task: task, option: .allExceptMyDay)
        infoView.attributedDetail = detailProvider.attributedInfo()
        
        /// 无有效目标数值时隐藏进度
        infoView.isProgressHidden = !task.isValidProgress
        setNeedsLayout()
    }
    
    /// 更新图标
    private func configureIcon(with item: TimelineItem, task: GoalTask) {
        let color: UIColor
        if item.startDate.isFutureDay {
            color = item.nodeColor
        } else {
            color = .white
        }
        
        let icon = resGetImage("goal_24", color: color)
        iconNodeView.configureIcon(icon)
    }
    
    func clickCheckbox() {
        guard let task = self.goalTask else {
            return
        }
        
        GoalTaskController().clickCheckbox(for: task)
    }
}
