//
//  HabitHomeDayListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/3.
//

import Foundation
import UIKit

class HabitHomeDayListCell: HabitTaskListDefaultInfoCell {

    var task: HabitPeriodTask? {
        didSet {
            self.habitTask = task?.habitTask
        }
    }
    
    let progressActionInfoView = HabitHomeDayActionInfoView()
    
    let detailProvider = HabitHomeDayTaskDetailProvider()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.padding = UIEdgeInsets(left: 16.0, right: 8.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var focusLineColor: UIColor {
        return task?.habitTask.color.lighterColor ?? .primary
    }
    
    override func setupInfoView() {
        self.infoView = progressActionInfoView
    }
    
    override func updateStyleWithColor(_ color: UIColor) {
        super.updateStyleWithColor(color)
        let progressView = progressActionInfoView.progressView
        progressView.progressLineColor = color.lighterColor
        progressView.backLineColor = Color(0x000000, 0.4)
    }
    
    /// 更新任务信息
    override func updateTaskInfo() {
        super.updateTaskInfo()
        self.updateProgress(animated: true)
        self.progressActionInfoView.updateRecordButton(with: task)
    }
    
    /// 更新详细文本
    override func updateSubtitle() {
        let titleView = self.infoView.titleView
        if let task = task {
            titleView.subtitle = detailProvider.detail(for: task)
        } else {
            titleView.subtitle = nil
        }
    }

    /// 更新进度
    func updateProgress(animated: Bool) {
        var progress: CGFloat = 0.0
        var status: HabitTaskStatus = .notStarted
        if let date = task?.period.date {
            progress = task?.progress(on: date) ?? 0.0
            status = task?.status(on: date) ?? .notStarted
        }
        
        progressActionInfoView.setProgress(progress, animated: animated)
        progressActionInfoView.setStatus(status, animated: animated)
    }
}

class HabitHomeDayTaskDetailProvider {
    
    /// 更新详细文本
    func detail(for task: HabitPeriodTask) -> TextRepresentable {
        let habitTask = task.habitTask
        let date = task.period.date
        if date.isFutureDay {
            return habitTask.goal.targetDescription
        }
        
        /// 进度详情
        let record = task.records?[date.dayIntegerKey]
        var targetAmountString: ASAttributedString
        if habitTask.goal.mode == .checkin {
            targetAmountString = "\(resGetString("1 time"))"
        } else {
            let progressFormat = resGetString("%ld %@")
            targetAmountString = "\(String(format: progressFormat, habitTask.goal.validatedTargetAmount, habitTask.goal.validatedUnit))"
        }
    
        let currentAmount = record?.amount ?? 0
        let progressDetail = "\(currentAmount)/" + targetAmountString
        guard let record = record else {
            return progressDetail
        }

        var details = [progressDetail]
        
        /// 备注
        if record.hasLog {
            details.append(habitTask.logIndicator(color: .white))
        }
        
        return details.joined(separator: "•")
    }
}


