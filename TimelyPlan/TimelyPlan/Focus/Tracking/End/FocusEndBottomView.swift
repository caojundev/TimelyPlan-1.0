//
//  FocusEndBottomView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/14.
//

import Foundation
import UIKit

class FocusEndBottomView: UIView {
    
    var didClickSave: (() -> Void)?
    
    var didClickDiscard: (() -> Void)?
    
    /// 保存按钮最大宽度
    private let saveButtonMaxWidth = 560.0
    private let saveButtonHeight = 60.0
    private let discardButtonHeight = 30.0
    private let discardButtonTopMargin = 10.0
    
    /// 保存按钮
    lazy var saveButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.title = resGetString("Save Focus Data")
        button.titleConfig.font = BOLD_SYSTEM_FONT
        button.cornerRadius = 16.0
        button.titleConfig.textColor = Color(0xFFFFFF, 0.8)
        button.normalBackgroundColor = Color(0x4A4DFF)
        button.selectedBackgroundColor = Color(0x4A4DFF).darkerColor
        button.addTarget(self, action: #selector(clickSave), for: .touchUpInside)
        return button
    }()
    
    /// 丢弃按钮
    lazy var discardButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        button.title = resGetString("Discard focus data of this round")
        button.titleConfig.textColor = .secondaryLabel
        button.addTarget(self,
                         action: #selector(clickDiscard),
                         for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        self.padding = UIEdgeInsets(horizontal: 20.0, vertical: 10.0)
        self.addSubview(saveButton)
        self.addSubview(discardButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = self.safeLayoutFrame()
        saveButton.width = min(saveButtonMaxWidth, layoutFrame.width)
        saveButton.height = saveButtonHeight
        saveButton.top = layoutFrame.minY
        saveButton.alignHorizontalCenter()
        
        discardButton.width = saveButton.width
        discardButton.height = discardButtonHeight
        discardButton.top = saveButton.bottom + discardButtonTopMargin
        discardButton.alignHorizontalCenter()
    }

    @objc func clickSave() {
        self.didClickSave?()
    }
    
    @objc func clickDiscard() {
        self.didClickDiscard?()
    }
    
}
