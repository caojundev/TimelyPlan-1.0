//
//  GoalTaskBindCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/12.
//

import Foundation
import UIKit

class GoalTaskBindCell: TPBaseTableCell, SearchHighlightable {
    
    var goalTask: GoalTask? {
        didSet {
            updateInfo()
        }
    }
    
    /// 选中按钮
    private let checkboxSize = CGSize(width: 20.0, height: 20.0)
    private let checkboxMargins = UIEdgeInsets(right: 15.0)
    private(set) lazy var checkbox: TPCircularCheckbox = {
        let checkbox = TPCircularCheckbox()
        checkbox.isUserInteractionEnabled = false
        checkbox.padding = .zero
        checkbox.innerColor = resGetColor(.title)
        checkbox.outerColor = checkbox.innerColor
        return checkbox
    }()
    
    private let infoView = GoalTaskBaseInfoView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        rightView = checkbox
        rightViewSize = checkboxSize
        rightViewMargins = checkboxMargins
        contentView.addSubview(infoView)
        contentView.padding = UIEdgeInsets(top: 8.0, left: 12.0, bottom: 8.0, right: 8.0)
        
        infoView.nameHeight = 22.0
        infoView.detailTopMargin = 2.0
        infoView.detailHeight = 18.0
        infoView.progressTopMargin = 6.0
        infoView.progressHeight = 3.0
        infoView.nameLabel.font = .boldSystemFont(ofSize: 14.0)
        infoView.nameLabel.numberOfLines = 1
        infoView.detailLabel.font = .systemFont(ofSize: 12.0)
        infoView.detailLabel.numberOfLines = 1
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkbox.setChecked(checked, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = availableLayoutFrame()
    }
    
    func updateInfo() {
        guard let goalTask = goalTask else {
            return
        }
        
        /// 标题（支持搜索高亮）
        if let taskName = goalTask.name,
           let highlightedText = highlightedText,
           highlightedText.count > 0 {
            let value = taskName.attributedStringWithHighlight(highlightedText,
                                                                normalAttributes: normalAttributes,
                                                                highlightAttributes: highlightAttributes)
            infoView.nameLabel.attributedText = value
        } else {
            infoView.name = goalTask.displayName
        }
        
        /// 进度
        infoView.isProgressHidden = goalTask.targetValue <= 0
        infoView.setProgress(goalTask.progressFraction)
        infoView.progressView.barForeColor = goalTask.color ?? GoalTask.defaultColor
        
        /// 详情
        let option: GoalTaskDetailOption = [.schedule, .progress, .weight]
        let detailProvider = GoalTaskDetailProvider(task: goalTask,
                                                    option: option)
        infoView.attributedDetail = detailProvider.attributedInfo()
        setNeedsLayout()
    }
    
    // MARK: - SearchHighlightable
    /// 高亮文本
    var highlightedText: String?
    
    /// 获取默认的正常文本属性
    /// - Note: 不能使用 nameLabel.textColor（`UIColor(.dm, ...)` 构造的自定义动态色），
    ///         其放入 NSAttributedString 后不会随 trait 正确解析，暗黑模式下会错误地显示为浅色值；
    ///         这里统一使用系统动态色 .label（与习惯/专注绑定单元一致）
    var normalAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: UIColor.label,
            .font: infoView.nameLabel.font ?? .boldSystemFont(ofSize: 14.0)
        ]
    }
    
    /// 获取默认的高亮文本属性（黄色背景，黑色文字）
    var highlightAttributes: [NSAttributedString.Key: Any] {
        return [
            .backgroundColor: Color(0xFFD60A),
            .foregroundColor: UIColor.black,
            .font: infoView.nameLabel.font ?? .boldSystemFont(ofSize: 14.0)
        ]
    }
    
    /// 设置搜索文本并更新高亮显示
    func setHighlightedText(_ highlightedText: String?) {
        self.highlightedText = highlightedText
        self.updateInfo()
    }
}
