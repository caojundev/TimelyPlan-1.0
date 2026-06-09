//
//  TodoTaskEditSectionTitleView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/9.
//

import Foundation
import UIKit

class TodoTaskEditSectionTitleView: UIView {
    
    var didClickSection: (() -> Void)?
    
    var section: TodoSectionFeature = .defaultSection {
        didSet {
            updateSectionTitle()
        }
    }

    var titleColor = Color(light: 0x646566, dark: 0xabacad)
    
    /// 列表选择按钮
    private lazy var sectionButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.imagePosition = .right
        button.imageConfig.size = .size(4)
        button.imageConfig.shouldRenderImageWithColor = true
        button.imageConfig.color = titleColor
        button.imageName = "chevron_upDown_16"
        button.titleConfig.textColor = titleColor
        button.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        button.addTarget(self, action: #selector(clickSection(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(sectionButton)
        updateSectionTitle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sectionButton.frame = bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return sectionButton.sizeThatFits(size)
    }
    
    func updateSectionTitle() {
        sectionButton.title = section.title
    }
    
    // MARK: - Event Response
    /// 点击板块按钮
    @objc func clickSection(_ button: UIButton) {
        didClickSection?()
    }
}
