//
//  TodoGroupSelectButton.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/27.
//

import Foundation

class TodoGroupSelectButton: TPDefaultButton {
    
    lazy var checkbox: TPCircularCheckbox = {
        let checkbox = TPCircularCheckbox()
        checkbox.isUserInteractionEnabled = false
        checkbox.innerColor = .white
        checkbox.outerColor = .white
        checkbox.outerLineWidth = 2
        return checkbox
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(top: 6.0,
                                    left: 10.0,
                                    bottom: 6.0,
                                    right: 24.0)
        self.normalBackgroundColor = .primary
        self.titleConfig.textColor = .white
        self.cornerRadius = 8.0
        self.imageTitleView.alpha = 0.8
        self.checkbox.alpha = 0.8
        self.titleLabel?.font = BOLD_SMALL_SYSTEM_FONT
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.contentView.addSubview(checkbox)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = self.layoutFrame()
        self.checkbox.size = CGSize(width: 12.0, height: 12.0)
        self.checkbox.left = layoutFrame.maxX + 5.0
        self.checkbox.centerY = layoutFrame.midY
    }
    
    override func setChecked(_ isChecked: Bool, animated: Bool = false) {
        super.setChecked(isChecked, animated: animated)
        self.checkbox.setChecked(isChecked, animated: animated)
    }
}
