//
//  HabitTaskListInfoCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/5.
//

import Foundation
import UIKit

protocol HabitTaskListInfoCellDelegate: AnyObject {
    
    /// 点击更多
    func habitTaskListInfoCell(_ cell: HabitTaskListDefaultInfoCell, didClickMore button: UIButton)
}

class HabitTaskListDefaultInfoCell: HabitTaskListBaseCell {
    
    var habitTask: HabitTask? {
        didSet {
            updateTaskInfo()
        }
    }
    
    var infoView: HabitTaskDefaultInfoView!
    
    /// 更多按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.imageConfig.color = Color(0xffffff, 0.8)
        button.addTarget(self,
                         action: #selector(clickMore(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override var focusLineColor: UIColor {
        return habitTask?.color.lighterColor ?? .primary
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupInfoView()
        contentView.addSubview(self.infoView)
        contentView.addSubview(self.moreButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupInfoView() {
        self.infoView = HabitTaskDefaultInfoView()
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        moreButton.sizeToFit()
        moreButton.right = layoutFrame.maxX
        moreButton.alignVerticalCenter()
        
        infoView.width = layoutFrame.width - moreButton.width
        infoView.height = layoutFrame.height
        infoView.origin = layoutFrame.origin
    }
    
    override func updateStyleWithColor(_ color: UIColor) {
        super.updateStyleWithColor(color)
        
        let iconView = infoView.iconView
        iconView.foreColor = Color(0xffffff, 0.8)
        iconView.backColor = color
        
        let titleView = infoView.titleView
        titleView.titleConfig.textColor = Color(0xffffff, 0.9)
        titleView.subtitleConfig.textColor = Color(0xffffff, 0.7)
    }
    
    func updateTaskInfo() {
        self.updateStyleWithColor(habitTask?.color ?? .primary)
        self.infoView.iconView.icon = habitTask?.icon
        self.infoView.titleView.title = habitTask?.name
        self.updateSubtitle()
    }
    
    func updateSubtitle() {
        self.infoView.titleView.subtitle = habitTask?.goal.targetDescription
    }
    
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        if let delegate = self.delegate as? HabitTaskListInfoCellDelegate {
            delegate.habitTaskListInfoCell(self, didClickMore: button)
        }
    }
}
