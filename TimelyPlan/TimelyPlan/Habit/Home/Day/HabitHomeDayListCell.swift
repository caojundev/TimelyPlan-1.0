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
    
    let progressInfoView = HabitTaskProgressInfoView()
    
    override var focusLineColor: UIColor {
        return task?.habitTask.color.lighterColor ?? .primary
    }
    
    override func setupInfoView() {
        self.infoView = progressInfoView
    }
    
    override func updateStyleWithColor(_ color: UIColor) {
        super.updateStyleWithColor(color)
        let progressView = progressInfoView.progressView
        progressView.progressLineColor = color.lighterColor
        progressView.backLineColor = Color(0x000000, 0.4)
    }
    
    /// 更新任务信息
    override func updateTaskInfo() {
        super.updateTaskInfo()
        self.updateProgress(animated: true)
    }
    
    /// 更新详细文本
    override func updateSubtitle() {
        let titleView = self.infoView.titleView
        guard let task = task else {
            titleView.subtitle = nil
            return
        }

        let date = task.period.date
        if date.isFutureDay {
            titleView.subtitle = task.habitTask.goal.targetDescription
            return
        }
        

        print(date.yearMonthDayString)
        
        /*
        guard !date.isFutureDay else {
            infoView.detailTextLabel.text = task.targetDescription
            return
        }

        var details = [ASAttributedString]()
        var targetAmountString: ASAttributedString
        if task.targetMode == .checkin {
            targetAmountString = "\(resGetString("1 time")!)"
        } else {
            let progressFormat = resGetString("%ld %@")!
            targetAmountString = "\(String(format: progressFormat, task.targetAmount, task.targetUnit))"
        }
        
        let amount = info?.amount ?? 0
        let progressDetail = "\(amount)/" + targetAmountString
        details.append(progressDetail)
    
        /// 失败
        if case let .failed(reason) = info?.status {
            let failDetail = task.failIndicator(reason: reason)
            details.append(failDetail)
        }
        
        /// 跳过
        if case let .skipped(reason) = info?.status {
            let skipDetail = task.skipIndicator(reason: reason)
            details.append(skipDetail)
        }
        
        /// 备注
        if let log = info?.log, log.count > 0 {
            details.append(task.logIndicator)
        }
        
        /// 随机频率，完成天数
        if task.timePlanType == .randomly, let daysCount = info?.randomlyCompletedDays {
            let daysFormat: String = resGetString("%ld \(daysCount > 1 ? "days" : "day")")
            let daysString = String(format: daysFormat, daysCount)

            let detailFormat: String
            let frequency = task.timePlan?.randomRule?.frequency ?? .weekly
            if frequency == .weekly {
                detailFormat = resGetString("%@ this week")
            } else {
                detailFormat = resGetString("%@ this month")
            }
            
            let description = String(format: detailFormat, daysString)
            details.append("\(description)")
        }
        
        infoView.detailTextLabel.attributed.text = details.joined(separator: " • ")
        */
    }

    /// 更新进度
    func updateProgress(animated: Bool) {
        let progress = CGFloat(arc4random() % 100) / 100.0
        progressInfoView.setProgress(progress, animated: animated)
        
        /// 更新状态视图
//        let status = info?.status ?? .notStarted
//        statusView.setStatus(status, animated: animated)
    }
    
}


