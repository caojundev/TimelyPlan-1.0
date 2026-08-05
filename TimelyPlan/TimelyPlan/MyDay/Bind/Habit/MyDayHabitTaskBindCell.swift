//
//  MyDayHabitTaskBindCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/29.
//

import Foundation
import UIKit

class MyDayHabitTaskBindCell: TPBaseTableCell, SearchHighlightable {
    
    var habitTask: HabitTask? {
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
    
    private let infoView = HabitTaskDefaultInfoView()

    override func setupContentSubviews() {
        super.setupContentSubviews()
        rightView = checkbox
        rightViewSize = checkboxSize
        rightViewMargins = checkboxMargins
        contentView.addSubview(infoView)
        contentView.padding = UIEdgeInsets(top: 4.0, left: 12.0, bottom: 4.0, right: 8.0)
    
        let titleColor = UIColor.label
        let iconView = infoView.iconView
        iconView.foreColor = titleColor
        iconView.backColor = Color(0xcccccc, 0.2)

        let titleView = infoView.titleView
        titleView.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        titleView.titleConfig.textColor = titleColor
        titleView.subtitleConfig.textColor = .secondaryLabel
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
        guard let habitTask = habitTask else {
            return
        }

        infoView.iconView.icon = habitTask.icon

        let titleView = infoView.titleView
        if let taskName = habitTask.name,
            let highlightedText = highlightedText,
            highlightedText.count > 0  {
            /// 高亮文本
            let value = taskName.attributedStringWithHighlight(highlightedText,
                                                                normalAttributes: normalAttributes,
                                                                highlightAttributes: highlightAttributes)
            titleView.title = ASAttributedString(value: value)
        } else {
            titleView.title = habitTask.displayName
        }
        
        let detailProvider = HabitTaskDetailProvider()
        let subtitle = detailProvider.detail(for: habitTask,
                                                on: .distantFuture,
                                                with: nil,
                                                color: .secondaryLabel,
                                                addToMyDayIncluded: true)
        titleView.subtitle = subtitle
    }
    
   
    // MARK: - SearchHighlightable
    /// 高亮文本
    var highlightedText: String?
    
    /// 获取默认的正常文本属性
    var normalAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: infoView.titleView.titleConfig.textColor ?? .label,
            .font: infoView.titleView.titleConfig.font
        ]
    }
    
    /// 获取默认的高亮文本属性（黄色背景，黑色文字）
    var highlightAttributes: [NSAttributedString.Key: Any] {
        return [
            .backgroundColor: Color(0xFFD60A),
            .foregroundColor: UIColor.black,
            .font: infoView.titleView.titleConfig.font
        ]
    }
    
    /// 设置搜索文本并更新高亮显示
    func setHighlightedText(_ highlightedText: String?) {
        self.highlightedText = highlightedText
        self.updateInfo()
    }
}
