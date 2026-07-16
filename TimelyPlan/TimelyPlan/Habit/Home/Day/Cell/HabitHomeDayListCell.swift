//
//  HabitHomeDayListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/3.
//

import Foundation
import UIKit

protocol HabitHomeDayListCellDelegate: HabitTaskListInfoCellDelegate {
    
    /// 点击记录按钮
    func habitHomeDayListCell(_ cell: HabitHomeDayListCell, didClickRecord button: UIButton)
}

class HabitHomeDayListCell: HabitTaskListDefaultInfoCell {

    var periodItem: HabitPeriodItem? {
        didSet {
            self.habitTask = periodItem?.habitTask
        }
    }
    
    let progressActionInfoView = HabitHomeDayActionInfoView()
    
    let detailProvider = HabitTaskDetailProvider()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.padding = UIEdgeInsets(left: 16.0, right: 8.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var focusLineColor: UIColor {
        return periodItem?.habitTask.color.lighterColor ?? .primary
    }
    
    override func setupInfoView() {
        self.progressActionInfoView.recordButton.addTarget(self,
                                                           action: #selector(clickRecord(_:)),
                                                           for: .touchUpInside)
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
        self.updateProgress(animated: false)
        self.updateRecordButton()
    }
    
    /// 更新详细文本
    override func updateSubtitle() {
        let titleView = self.infoView.titleView
        if let periodItem = periodItem {
            titleView.subtitle = detailProvider.detail(for: periodItem)
        } else {
            titleView.subtitle = nil
        }
    }

    /// 更新进度
    private func updateProgress(animated: Bool) {
        var progress: CGFloat = 0.0
        var status: HabitTaskStatus = .notStarted
        if let date = periodItem?.period.date {
            progress = periodItem?.progress(on: date) ?? 0.0
            status = periodItem?.status(on: date) ?? .notStarted
        }
        
        progressActionInfoView.setProgress(progress, animated: animated)
        progressActionInfoView.setStatus(status, animated: animated)
    }
    
    private func updateRecordButton() {
        self.progressActionInfoView.updateRecordButton(with: self.periodItem)
    }

    @objc private func clickRecord(_ button: UIButton) {
        if let delegate = delegate as? HabitHomeDayListCellDelegate {
            delegate.habitHomeDayListCell(self, didClickRecord: button)
        }
    }

    private func didChangeRecord(withIncreament amount: Int) {
        guard amount != 0 else { return }
        let text = (amount >= 0 ? "+" : "") + "\(amount)"
        let color = periodItem?.habitTask.color.lighterColor ?? .label
        let font = BOLD_SYSTEM_FONT
        let fromView = infoView.titleView.titleLabel
        let sourceWidth = text.width(with: font)
        let sourceRect = CGRect(x: 0.0, y: 0.0, width: sourceWidth, height: fromView.height)
        
        let containerView = self.parentViewController?.view
        TPTextPopUp.showText(text,
                             color: color,
                             font: font,
                             fromView: fromView,
                             sourceRect: sourceRect,
                             containerView: containerView)
    }
    
    /// 记录更新
    func updateRecord(with change: HabitRecordChange?, animated: Bool = true) {
        updateSubtitle()
        updateRecordButton()
        updateProgress(animated: animated)
        
        if animated, case let .amountChanged(oldValue, newValue) = change {
            self.didChangeRecord(withIncreament: Int(newValue - oldValue))
        }
    }
}

class HabitTaskDetailProvider {
    
    /// 完成数目详情文本
    static func completedAmountDetail(for task: HabitTask, with record: HabitRecord?) -> ASAttributedString {
        var targetAmountString: ASAttributedString
        if task.goal.mode == .checkin {
            targetAmountString = "\(resGetString("1 time"))"
        } else {
            let progressFormat = resGetString("%ld %@")
            targetAmountString = "\(String(format: progressFormat, task.goal.validatedTargetAmount, task.goal.validatedUnit))"
        }
    
        let currentAmount = record?.amount ?? 0
        let completedAmountDetail = "\(currentAmount)/" + targetAmountString
        return completedAmountDetail
    }
    
    /// 更新详细文本
    func detail(for periodItem: HabitPeriodItem) -> TextRepresentable {
        let date = periodItem.period.date
        let result = detail(for: periodItem, on: date, color: .white)
        let task = periodItem.habitTask
        guard task.isAddedToMyDay else {
            return result
        }
        
        /// 添加我的一天信息
        var components = [result]
        if let myDayIndicator = task.myDayIndicator(color: .white) {
            components.append(myDayIndicator)
        }
        
        return components.joined(separator: " • ")
    }
    
    /// 更新详细文本
    func detail(for periodItem: HabitPeriodItem,
                on date: Date,
                color: UIColor = .white) -> ASAttributedString {
        let task = periodItem.habitTask
        if date.isFutureDay {
            return task.goal.targetDescription.attributedString
        }
        
        /// 进度详情
        let record = periodItem.records?[date.dayIntegerKey]
        let progressDetail = Self.completedAmountDetail(for: task, with: record)
        guard let record = record else {
            return progressDetail
        }

        var details = [progressDetail]
        
        /// 备注
        if record.hasLog {
            details.append(task.logIndicator(color: color))
        }
        
        return details.joined(separator: " • ")
    }
}


