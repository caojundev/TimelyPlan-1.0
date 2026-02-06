//
//  TodoTaskCheckbox.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/6.
//

import Foundation
import UIKit

struct TodoTaskCheckboxConfig: Equatable {
    
    var size: CGSize
    
    var cornerRadius: CGFloat
    
    var borderWidth: CGFloat
    
    var checkmarkLineWidth: CGFloat
    
    static var normal: TodoTaskCheckboxConfig {
        return TodoTaskCheckboxConfig(size: .size(5),
                                      cornerRadius: 5.0,
                                      borderWidth: 2.0,
                                      checkmarkLineWidth: 3.0)
    }
    
    static var small: TodoTaskCheckboxConfig {
        return TodoTaskCheckboxConfig(size: .size(4),
                               cornerRadius: 4.0,
                               borderWidth: 1.6,
                               checkmarkLineWidth: 1.8)
    }
}

class TodoTaskCheckbox: TPImageButton {
    
    enum Mode: Int {
        case normal /// 正常
        case plus   /// 加
        case minus  /// 减
    }
    
    var mode: Mode = .normal {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 正常颜色
    var normalColor: UIColor = .grayPrimary {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 选中状态颜色
    var checkedColor: UIColor = .primary {
        didSet {
            setNeedsLayout()
        }
    }
    
    var config: TodoTaskCheckboxConfig = .normal {
        didSet {
            updateCheckboxConfig()
        }
    }
    
    private lazy var checkmarkLayer: TPCheckmarkLayer = {
        let layer = TPCheckmarkLayer()
        return layer
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.layer.addSublayer(checkmarkLayer)
        normalBackgroundColor = .clear
        updateCheckboxConfig()
    }
    
    override func layoutSubviews() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        super.layoutSubviews()
        updateCheckBoxStyle()
        checkmarkLayer.frame = bounds.middleCircleInnerSquareRect
        CATransaction.commit()
    }
    
    override func setChecked(_ isChecked: Bool, animated: Bool = false) {
        super.setChecked(isChecked, animated: animated)
        updateCheckBoxStyle()
        checkmarkLayer.setChecked(isChecked, animated: animated)
    }
    
    private func updateCheckboxConfig() {
        imageSize = config.size
        borderWidth = config.borderWidth
        cornerRadius = config.cornerRadius
        checkmarkLayer.lineWidth = config.checkmarkLineWidth
    }
    
    private func updateCheckBoxStyle() {
        if self.isChecked {
            normalImageColor = .green
            normalBorderColor = checkedColor
            selectedBorderColor = checkedColor
            normalBackgroundColor = checkedColor
            selectedBackgroundColor = checkedColor
        } else {
            normalImageColor = normalColor
            normalBorderColor = normalColor
            selectedBorderColor = normalColor
            normalBackgroundColor = .clear
            selectedBackgroundColor = .clear
        }
    }
    
    override var currentImage: UIImage? {
        if isChecked  {
            return nil
        }
        
        switch mode {
        case .plus:
            return resGetImage("todo_task_checkbox_plus_20")
        case .minus:
            return resGetImage("todo_task_checkbox_minus_20")
        default:
            return nil
        }
    }
}
