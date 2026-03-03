//
//  HabitTimeSelectView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/2.
//

import Foundation
import UIKit

class HabitTimeSelectView: UIView {
    
    /// 选中时间回调
    var didSelectTimeOption: ((HabitTimeOption) -> Void)?
    
    // 当前选中的时间选项
    var selectedOption: HabitTimeOption = .anytime {
        didSet {
            updateTimeButtonsAppearance()
        }
    }
    
    // 存放所有时间选项按钮的数组
    private var timeButtons: [HabitTimeOptionButton] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(value: 8.0)
        for option in HabitTimeOption.allCases {
            let button = HabitTimeOptionButton(option: option)
            button.addTarget(self, action: #selector(timeOptionButtonTapped(_:)), for: .touchUpInside)
            timeButtons.append(button)
            addSubview(button)
        }
        
        updateTimeButtonsAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        let spacing = 8.0
        let buttonWidth = (layoutFrame.width - spacing) / 2.0
        let buttonHeight = (layoutFrame.height - spacing) / 2.0
        for (index, button) in timeButtons.enumerated() {
            let row = index / 2
            let col = index % 2
            let x = layoutFrame.minX + Double(col) * (spacing + buttonWidth)
            let y = layoutFrame.minY + Double(row) * (spacing + buttonHeight)
            button.frame = CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)
        }
    }

    @objc private func timeOptionButtonTapped(_ sender: HabitTimeOptionButton) {
        TPImpactFeedback.impactWithSoftStyle()
        selectedOption = sender.option
        didSelectTimeOption?(selectedOption)
    }

    /// 根据当前的 selectedOption 更新所有按钮的外观
    private func updateTimeButtonsAppearance() {
        for button in timeButtons {
            button.isSelected = button.option == selectedOption
        }
    }
}

class HabitTimeOptionButton: TPDefaultButton {
    
    private let selectedTextColor: UIColor = .white
    private let normalTextColor: UIColor = resGetColor(.title).withAlphaComponent(0.3)

    let option: HabitTimeOption
    
    init(option: HabitTimeOption) {
        self.option = option
        super.init(frame: .zero)
        self.title = option.title
        self.titleConfig.textColor = normalTextColor
        self.titleConfig.highlightedTextColor = selectedTextColor
        self.titleConfig.selectedTextColor = selectedTextColor
        
        self.image = option.iconImage
        self.imagePosition = .left
        self.imageConfig.size = .size(6)
        self.imageConfig.color = normalTextColor
        self.imageConfig.highlightedColor = selectedTextColor
        self.imageConfig.selectedColor = selectedTextColor
        
        self.normalBackgroundColor = Color(0xcccccc, 0.1)
        self.selectedBackgroundColor = .primary
        self.cornerRadius = 6.0
        self.scaleMaxLength = 5.0
        self.preferredTappedScale = 0.95
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
