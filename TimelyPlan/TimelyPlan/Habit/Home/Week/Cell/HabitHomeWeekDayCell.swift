//
//  HabitHomeWeekDayCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/7.
//

import Foundation
import UIKit

class HabitHomeWeekDayCell: HabitTaskStatusSymbolProgressValueCell {
    
    var task: HabitPeriodTask?
    
    /// 日期
    var date: Date?
    
    /// 是否是计划日
    var isScheduledDay: Bool = true
    
    private var taskColor: UIColor {
        return task?.habitTask.color ?? .primary
    }
    
    /// 非计划日状态图片
    private lazy var notScheduledImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = resGetImage("habit_week_day_notscheduled_42")
        imageView.alpha = 0.5
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        insertSubview(notScheduledImageView, belowSubview: statusProgressView)
        notScheduledImageView.isHidden = true
        symbolLabel.textColor = Color(0xf1f1f1)
        symbolLabel.alpha = 0.6
        valueLabel.alpha = 0.8
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        notScheduledImageView.size = CGSize(width: 42.0, height: 42.0)
        notScheduledImageView.center = statusProgressView.center
    }
    
    /// 更新是否是计划日
    private func updateScheduleStatus() {
        self.notScheduledImageView.isHidden = isScheduledDay
        self.statusProgressView.isHidden = !isScheduledDay
    }
    
    /// 更新日期信息
    private func updateDateInfo() {
        guard let date = date else {
            return
        }

        self.contentView.alpha = date.isFutureDay ? 0.4 : 1.0
        self.symbolLabel.text = date.shortWeekdaySymbol()
        self.statusProgressView.infoLabel.text = "\(date.day)"
    }
    
    /// 更新样式
    private func updateStyle() {
        guard let task = task, let date = date else {
            return
        }

        let status = task.status(on: date)
        let color = taskColor.lighterColor
        
        
        /// 背景色
        if !isScheduledDay {
            backgroundView?.backgroundColor = .clear
            selectedBackgroundView?.backgroundColor = .clear
        } else if status == .completed {
            backgroundView?.backgroundColor = color
            selectedBackgroundView?.backgroundColor = color
        } else {
            backgroundView?.backgroundColor = UIColor(white: 0.6, alpha: 0.2)
            selectedBackgroundView?.backgroundColor = UIColor(white: 0.6, alpha: 0.3)
        }
        
        self.statusProgressView.statusImageColor = .white
        self.statusProgressView.progressColor = color
        self.statusProgressView.infoLabel.textColor = Color(0xffffff, 0.8)
        self.statusProgressView.progressColor = color
        self.valueLabel.textColor = color
    }
    
    /// 更新进度
    private func updateProgress(animated: Bool) {
        var progress: CGFloat = 0.0
        if let date = self.date {
            progress = task?.progress(on: date) ?? 0.0
        }
        
        self.progressView.setProgress(progress, animated: animated)
    }
    
    private func updateValueStatus() {
        guard let task = task, let date = date else {
            return
        }

        let status = task.status(on: date)
        /// 更新 status
        self.statusProgressView.status = status
        
        /// 更新 valueLabel
        guard isScheduledDay else {
            valueLabel.text = nil
            setNeedsLayout()
            return
        }
        
        var details: [ASAttributedString] = []
        let color = taskColor.lighterColor
        if status == .failed(nil) {
            details.append(.failIndicator(color: color))
        } else if status == .skipped(nil) {
            details.append(.skipIndicator(color: color))
        }
        
        let record = task.record(on: date)
        if let record = record, record.hasLog {
            details.append(.logIndicator(color: color))
        }
        
        /// 数量
        let amount = record?.amount ?? 0
        if amount > 0 {
            if task.habitTask.goal.mode == .checkin {
                /// 打卡
                let checkedInIndicator = ASAttributedString.checkedInIndicator(color: color)
                details.insert(checkedInIndicator, at: 0)
            } else {
                /// 定量
                let amountNumber = NSNumber(value: amount)
                details.append("\(amountNumber.decimalStyleString)")
            }
        }
        
        if details.count > 0 {
            valueLabel.attributed.text = details.joined(separator: "•")
        } else {
            valueLabel.text = nil
        }

        setNeedsLayout()
    }
    
    private func didChangeRecord(withIncreament amount: Int) {
        guard amount != 0 else { return }
        let text = (amount >= 0 ? "+" : "") + "\(amount)"
        let color = task?.habitTask.color.lighterColor ?? .label
        TPTextPopUp.showText(text, color: color, font: SMALL_SYSTEM_FONT, fromView: valueLabel)
    }
    
    /// 记录更新
    func updateRecord(with change: HabitRecordChange?, animated: Bool = true) {
        self.updateScheduleStatus()
        self.updateStyle()
        self.updateDateInfo()
        self.updateValueStatus()
        self.updateProgress(animated: animated)
        if animated, case let .amountChanged(oldValue, newValue) = change {
            self.didChangeRecord(withIncreament: Int(newValue - oldValue))
        }
    }
    
    /// 加载数据
    func reloadData() {
        self.updateScheduleStatus()
        self.updateStyle()
        self.updateDateInfo()
        self.updateValueStatus()
        self.updateProgress(animated: false)
    }
    
}
