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
    
    private var taskColor: UIColor {
        return task?.habitTask.color ?? .primary
    }
    
    /// 非计划日状态图片
    private lazy var notScheduledImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = resGetImage("HabitDayNotScheduled_40pt")
        imageView.alpha = 0.2
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
        notScheduledImageView.frame = statusProgressView.frame
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
    
    /// 更新任务信息
    private func updateStyleWithColor(_ color: UIColor) {
        self.valueLabel.textColor = color
        self.statusProgressView.progressColor = color
    }
    
    /// 更新进度
    private func updateProgress(animated: Bool) {
        var progress: CGFloat = 0.0
        if let date = self.date {
            progress = task?.progress(on: date) ?? 0.0
        }
        
        self.progressView.setProgress(progress, animated: animated)
    }
    
    private func updateValue() {
        guard let task = task, let date = date else {
            return
        }

        let status = task.status(on: date)
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
        TPTextPopUp.showText(text,
                             color: color,
                             font: SMALL_SYSTEM_FONT,
                             fromView: valueLabel)
    }
    
    /// 加载数据
    func reloadData() {
        self.updateStyleWithColor(taskColor.lighterColor)
        self.updateDateInfo()
        self.updateValue()
        self.updateProgress(animated: false)
    }
    
    /// 记录更新
    func updateRecord(with change: HabitRecordChange?, animated: Bool = true) {
        self.updateDateInfo()
        self.updateValue()
        self.updateProgress(animated: animated)
        if animated, case let .amountChanged(oldValue, newValue) = change {
            self.didChangeRecord(withIncreament: Int(newValue - oldValue))
        }
    }
    
}
