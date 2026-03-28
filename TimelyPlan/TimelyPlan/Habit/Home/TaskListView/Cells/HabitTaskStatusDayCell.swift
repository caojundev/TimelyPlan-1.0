//
//  HabitTaskStatusDayCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/15.
//

import Foundation

class HabitTaskStatusDayCell: HabitTaskStatusProgressValueCell {
    
    var periodItem: HabitPeriodItem?
    
    /// 日期
    var date: Date?
    
    /// 是否是计划日
    var isScheduledDay: Bool = true
    
    var taskColor: UIColor {
        return periodItem?.habitTask.color ?? .primary
    }
    
    /// 非计划日状态图片
    private(set) lazy var notScheduledImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = resGetImage("habit_week_day_notscheduled_42")
        imageView.alpha = 0.0
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
        valueLabel.alpha = 0.8
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        notScheduledImageView.size = CGSize(width: 42.0, height: 42.0)
        notScheduledImageView.center = statusProgressView.center
    }
    
    /// 更新是否是计划日
    private func updateScheduleStatus(animated: Bool = false) {
        let isScheduled = self.isScheduledDay
        let executeBlock = {
            self.notScheduledImageView.alpha = isScheduled ? 0.0 : 0.6
            self.statusProgressView.alpha = isScheduled ? 1.0 : 0.0
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: executeBlock)
        } else {
            executeBlock()
        }
    }
    
    /// 更新日期信息
    func updateDateInfo() {
        guard let date = date else {
            return
        }

        self.contentView.alpha = date.isFutureDay ? 0.25 : 1.0   
        self.statusProgressView.infoLabel.text = "\(date.day)"
    }
    
    /// 更新样式
    func updateStyle() {
        guard let periodItem = periodItem, let date = date else {
            return
        }

        let status = periodItem.status(on: date)
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
        self.valueLabel.textColor = color
        self.emptyLineColor = Color(0xf1f1f1, 0.2)
    }
    
    /// 更新进度
    private func updateProgress(animated: Bool) {
        var progress: CGFloat = 0.0
        if let date = self.date {
            progress = periodItem?.progress(on: date) ?? 0.0
        }
        
        self.progressView.setProgress(progress, animated: animated)
    }
    
    private func updateValueStatus(animated: Bool = false) {
        guard let periodItem = periodItem, let date = date else {
            return
        }

        let status = periodItem.status(on: date)
        /// 更新 status
        self.statusProgressView.setStatus(status, animated: animated)
        
        /// 更新 valueLabel
        guard isScheduledDay else {
            valueLabel.text = nil
            setNeedsLayout()
            return
        }
        
        var details: [ASAttributedString] = []
        let color = valueLabel.textColor ?? .label
        if status.isFailed {
            details.append(.failIndicator(color: color))
        } else if status.isSkipped {
            details.append(.skipIndicator(color: color))
        } else {
            let record = periodItem.record(on: date)
            let amount = record?.amount ?? 0
            if amount > 0 {
                if periodItem.habitTask.goal.mode == .checkin {
                    /// 打卡
                    let checkedInIndicator = ASAttributedString.checkedInIndicator(color: color)
                    details.insert(checkedInIndicator, at: 0)
                } else {
                    /// 定量
                    let amountNumber = NSNumber(value: amount)
                    details.append("\(amountNumber.decimalStyleString)")
                }
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
        let color = periodItem?.habitTask.color.lighterColor ?? .label
        let containerView = self.parentViewController?.view
        TPTextPopUp.showText(text,
                             color: color,
                             font: SMALL_SYSTEM_FONT,
                             fromView: valueLabel,
                             containerView: containerView)
    }
    
    /// 记录更新
    func updateRecord(with change: HabitRecordChange?, animated: Bool = true) {
        self.updateScheduleStatus(animated: animated)
        self.updateStyle()
        self.updateDateInfo()
        self.updateValueStatus(animated: animated)
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
