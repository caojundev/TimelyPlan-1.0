//
//  TPStepperView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/22.
//

import Foundation
import UIKit

class TPStepperView: UIView {
    
    var valueDidChange: ((Int) -> Void)?
    
    var didClickValue: ((UIView) -> Void)?
    
    var minimumValue: Int = 0 {
        didSet {
            if minimumValue != oldValue {
                updateContent()
            }
        }
    }
    
    var maximumValue: Int = 100 {
        didSet {
            if maximumValue != oldValue {
                updateContent()
            }
        }
    }
    
    var step: Int = 1

    var value: Int {
        get {
            return min(max(minimumValue, _value), maximumValue)
        }
        
        set {
            _value = min(max(minimumValue, newValue), maximumValue);
            updateContent()
        }
    }
    
    private var _value: Int = 0
    
    lazy var valueButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = UIEdgeInsets(horizontal: 10.0)
        button.titleConfig.textColor = .label
        button.titleConfig.font = BOLD_BODY_FONT
        button.addTarget(self, action: #selector(clickValue(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var plusButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = .zero
        button.disabledAlpha = 0.3
        button.image = resGetImage("StepperPositive")
        button.imageConfig.color = .label
        button.imageConfig.size = .default
        button.addTarget(self, action: #selector(clickPlus(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var minusButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = .zero
        button.disabledAlpha = 0.3
        button.image = resGetImage("StepperNegative")
        button.imageConfig.color = .label
        button.imageConfig.size = .default
        button.addTarget(self, action: #selector(clickMinus(_:)), for: .touchUpInside)
        return button
    }()

    // 初始化方法可以根据需要添加
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }

    private func setupButtons() {
        self.addSubview(self.minusButton)
        self.addSubview(self.plusButton)
        self.addSubview(self.valueButton)
        self.updateContent()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        minusButton.sizeToFit()
        minusButton.left = 0.0
        minusButton.alignVerticalCenter()
        
        plusButton.sizeToFit()
        plusButton.right = self.width
        plusButton.alignVerticalCenter()
        
        valueButton.left = minusButton.right
        valueButton.width = plusButton.left - minusButton.right
        valueButton.height = self.height
    }

    private func updateContent() {
        minusButton.isEnabled = (self.value > minimumValue)
        plusButton.isEnabled = (self.value < maximumValue)
        valueButton.title = "\(self.value)"
    }

    @objc func clickValue(_ button: TPDefaultButton) {
        self.didClickValue?(button)
    }

    @objc func clickPlus(_ button: TPDefaultButton) {
        let oldValue = self.value
        self.value = oldValue + step
        if self.value != oldValue {
            self.valueDidChange?(self.value)
        }
    }

    @objc func clickMinus(_ button: TPDefaultButton) {
        let oldValue = self.value
        self.value = oldValue - step
        if self.value != oldValue {
            self.valueDidChange?(self.value)
        }
    }
}
