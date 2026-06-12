//
//  HabitTaskBindCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/29.
//

import Foundation
import UIKit

class HabitTaskBindCell: TPBaseTableCell {
    
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
    
    private let infoView = HabitTaskDefaultInfoView()

    override func setupContentSubviews() {
        super.setupContentSubviews()
        rightView = checkbox
        rightViewSize = checkboxSize
        rightViewMargins = checkboxMargins
        contentView.addSubview(infoView)
        contentView.padding = UIEdgeInsets(top: 4.0, left: 12.0, bottom: 4.0, right: 8.0)
    
        let titleColor = resGetColor(.title)
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
    
    
    func updateTaskInfo() {
        infoView.iconView.icon = habitTask?.icon
        infoView.titleView.title = habitTask?.name ?? resGetString("Untitled Habit")
        infoView.titleView.subtitle = habitTask?.goal.targetDescription
    }
    
}
