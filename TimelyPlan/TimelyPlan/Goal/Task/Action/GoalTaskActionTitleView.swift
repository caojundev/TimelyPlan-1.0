//
//  GoalTaskActionTitleView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/10.
//

import Foundation
import UIKit

class GoalTaskActionTitleView: UIView {
    
    var onClickHandler: (() -> Void)?
    
    var goalPlan: GoalPlanFeature? {
        didSet {
            updateTitle()
        }
    }

    var titleColor = Color(light: 0x646566, dark: 0xabacad)
    
    /// 列表选择按钮
    private lazy var titleButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.imagePosition = .right
        button.imageConfig.size = .size(4)
        button.imageConfig.shouldRenderImageWithColor = true
        button.imageConfig.color = titleColor
        button.imageName = "chevron_upDown_16"
        button.titleConfig.textColor = titleColor
        button.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        button.addTarget(self, action: #selector(clickTitle(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleButton)
        updateTitle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleButton.frame = bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return titleButton.sizeThatFits(size)
    }
    
    func updateTitle() {
        guard let goalPlan = goalPlan else {
            titleButton.isHidden = true
            return
        }

        titleButton.isHidden = false
        titleButton.title = goalPlan.attributedTitle
    }

    // MARK: - Event Response
    @objc func clickTitle(_ button: UIButton) {
        onClickHandler?()
    }
}
