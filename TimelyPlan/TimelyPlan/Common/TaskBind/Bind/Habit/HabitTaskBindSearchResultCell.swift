//
//  HabitTaskBindSearchResultCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/29.
//

import Foundation
import UIKit

class HabitTaskBindSearchResultCell: TPDefaultInfoTableCell,
                                     SearchHighlightable {
    
    var habitTask: HabitTask? {
        didSet {
            updateTaskInfo()
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
    
    override func setupInfoView() {
        super.setupInfoView()
        leftView = checkbox
        leftViewSize = checkboxSize
        leftViewMargins = checkboxMargins
    }
    
    func updateTaskInfo() {
        let name = habitTask?.name ?? resGetString("Untitled Habit")
        self.infoView.title = name
        self.infoView.subtitle = habitTask?.goal.targetDescription
        if let highlightedText = highlightedText,
            highlightedText.count > 0,
            let taskName = self.habitTask?.name {
            let value = taskName.attributedStringWithHighlight(highlightedText,
                                                                normalAttributes: normalAttributes,
                                                                highlightAttributes: highlightAttributes)
            self.infoView.title = ASAttributedString(value: value)
        }
    }

    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkbox.setChecked(checked, animated: animated)
    }
    
    // MARK: -
    
    /// 高亮文本
    var highlightedText: String?
    
    var normalAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: infoView.titleConfig.textColor ?? .label,
            .font: infoView.titleConfig.font
        ]
    }

    var highlightAttributes: [NSAttributedString.Key: Any] {
        return [
            .backgroundColor: Color(0xFFD60A),
            .foregroundColor: UIColor.black,
            .font: infoView.titleConfig.font
        ]
    }
    
    /// 设置搜索文本并更新高亮显示
    func setHighlightedText(_ highlightedText: String?) {
        self.highlightedText = highlightedText
        self.updateTaskInfo()
    }
}
