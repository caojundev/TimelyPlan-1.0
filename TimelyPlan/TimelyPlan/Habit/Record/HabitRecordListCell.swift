//
//  HabitRecordListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/21.
//

import Foundation
import UIKit

class HabitRecordListCell: HabitTaskListDefaultInfoCell {
    
    var dailyItem: HabitDailyItem? {
        didSet {
            self.habitTask = dailyItem?.task
        }
    }
    
    private let progressInfoView = HabitRecordListInfoView()
    
    private let scoreView = TPInfoView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.coverView.isHidden = true
        self.contentView.padding = UIEdgeInsets(top: 4.0, left: 12.0, bottom: 4.0, right: 8.0)
        self.moreButton.imageConfig.color = resGetColor(.title)
        self.shadowView.layer.shadowColor = Color(0x343434, 0.1).cgColor
        self.shadowView.layer.shadowOffset = CGSize(width:0, height: 2.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupInfoView() {
        progressInfoView.titleView.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        self.infoView = progressInfoView
    }
    
    override func setupContentSubviews() {
        scoreView.titleConfig.font = .boldSystemFont(ofSize: 20.0)
        scoreView.subtitleConfig.font = .boldSystemFont(ofSize: 10.0)
        scoreView.titleConfig.textAlignment = .center
        scoreView.subtitleConfig.textAlignment = .center
        scoreView.title = "--"
        scoreView.subtitle = resGetString("Score")
        scoreView.addSeparator(position: .left, color: Color(0xaaaaaa, 0.1))
        scoreView.separatorEdgeInset = UIEdgeInsets(vertical: 16.0)
        contentView.addSubview(scoreView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        scoreView.width = 60.0
        scoreView.height = layoutFrame.height
        scoreView.top = layoutFrame.minY
        scoreView.right = self.moreButton.left
        self.infoView.width = self.scoreView.left - self.infoView.left
    }
    
    override func updateStyleWithColor(_ color: UIColor) {
        let titleColor = resGetColor(.title)
        let iconView = infoView.iconView
        iconView.foreColor = titleColor
        iconView.backColor = Color(0xcccccc, 0.1)
        
        let titleView = infoView.titleView
        titleView.titleConfig.textColor = titleColor
        titleView.subtitleConfig.textColor = .secondaryLabel
        
        let progressView = progressInfoView.progressView
        progressView.progressLineColor = color
        progressView.backLineColor = Color(0xaaaaaa, 0.1)
    }
    
    override func updateCellStyle() {
        super.updateCellStyle()
        backgroundView?.backgroundColor = .secondarySystemGroupedBackground
        selectedBackgroundView?.backgroundColor = .secondarySystemGroupedBackground
    }
    
    /// 更新任务信息
    override func updateTaskInfo() {
        super.updateTaskInfo()
        self.updateProgress(animated: false)
        
        /// 更新评分
        let record = self.dailyItem?.record
        let score = record?.score ?? 0
        self.scoreView.title = "\(score)"
        self.progressInfoView.log = record?.log
    }
    
    /// 更新详细文本
    override func updateSubtitle() {
        let titleView = self.infoView.titleView
        titleView.subtitle = subtitle()
    }

    /// 更新进度
    private func updateProgress(animated: Bool) {
        let progress = dailyItem?.progress ?? 0.0
        progressInfoView.setProgress(progress, animated: animated)
        
        let status = dailyItem?.status ?? .notStarted
        progressInfoView.setStatus(status, animated: animated)
    }
    
    /// 详细文本
    private func subtitle() -> TextRepresentable? {
        guard let dailyItem = dailyItem else {
            return nil
        }

        let task = dailyItem.task
        let record = dailyItem.record
        var details = [ASAttributedString]()
        let amountDetail = HabitTaskDetailProvider.completedAmountDetail(for: task, with: record)
        details.append(amountDetail)
        
        let progress = task.progress(with: record)
        if progress != 0.0, progress != 1.0 {
            let progressPercentDetail = Float(progress).attributedPercentageString(decimalPlaces: 0)
            details.append(progressPercentDetail)
        }
        
        let status = task.status(with: record)
        switch status {
        case .skipped(let reason), .failed(let reason):
            if let reason = reason, reason.count > 0 {
                details.append(reason.attributedString)
            }
        default:
            break
        }
        
        return details.joined(separator: "•")
    }
}


class HabitRecordListInfoView: HabitTaskProgressInfoView {
    
    var log: String? {
        didSet {
            logLabel.text = log
            setNeedsLayout()
        }
    }
    
    lazy var logLabel: TPLabel = {
        let label = TPLabel()
        label.font = .boldSystemFont(ofSize: 10.0)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .tertiaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.logLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        let titleWidth = titleView.width
        logLabel.width = titleWidth
        logLabel.edgeInsets = UIEdgeInsets(left: titleView.padding.left,
                                           right: titleView.padding.right)
        if let log = logLabel.text, log.count > 0 {
            logLabel.height = 20.0
        } else {
            logLabel.height = 0.0
        }

        logLabel.left = titleView.left
        
        titleView.sizeToFit()
        titleView.width = titleWidth
        titleView.left = iconView.right
        titleView.top = layoutFrame.minY + (layoutFrame.height - (titleView.height + logLabel.height)) / 2.0
        logLabel.top = titleView.bottom
    }
}
