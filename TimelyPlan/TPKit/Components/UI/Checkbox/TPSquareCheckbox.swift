//
//  TPSquareCheckbox.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/19.
//

import Foundation
import UIKit

class TPSquareCheckbox: TPBaseButton {
    
    var normalColor: UIColor = Color(light: 0x646566, dark: 0xabacad) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var checkedColor: UIColor = Color(0x456FEF) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var checkmarkLineWidth: CGFloat = 3.0 {
        didSet {
            self.checkmarkLayer.lineWidth = checkmarkLineWidth
        }
    }
    
    private lazy var checkmarkLayer: TPCheckmarkLayer = {
        let layer = TPCheckmarkLayer()
        layer.lineWidth = checkmarkLineWidth
        return layer
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.contentView.layer.addSublayer(checkmarkLayer)
        self.normalBackgroundColor = .clear
        self.borderWidth = 2.0
        self.cornerRadius = 5.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateCheckBoxStyle()
        self.checkmarkLayer.frame = bounds.middleCircleInnerSquareRect
    }
    
    override func setChecked(_ isChecked: Bool, animated: Bool = false) {
        super.setChecked(isChecked, animated: animated)
        self.updateCheckBoxStyle()
        self.checkmarkLayer.setChecked(isChecked, animated: animated)
    }
    
    func updateCheckBoxStyle() {
        if self.isChecked {
            self.normalBorderColor = checkedColor
            self.selectedBorderColor = checkedColor
            self.normalBackgroundColor = checkedColor
            self.selectedBackgroundColor = checkedColor
        } else {
            self.normalBorderColor = normalColor
            self.selectedBorderColor = normalColor
            self.normalBackgroundColor = .clear
            self.selectedBackgroundColor = .clear
        }
    }
    
}
