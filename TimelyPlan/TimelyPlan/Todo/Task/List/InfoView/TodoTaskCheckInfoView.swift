//
//  TodoTaskCheckInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/13.
//

import Foundation
import UIKit

class TodoTaskCheckInfoView: TodoTaskBaseInfoView {
    
    /// 点击复选框
    var didClickCheckbox: ((TodoTaskCheckbox) -> Void)?
    
    /// 检查按钮
    private let checkboxSize = CGSize(width: 20.0, height: 20.0)
    private let checkboxMargins = UIEdgeInsets(right: 15.0)
    private(set) lazy var checkbox: TodoTaskCheckbox = {
        let checkbox = TodoTaskCheckbox()
        checkbox.hitTestEdgeInsets = UIEdgeInsets(horizontal: -20.0, vertical: -20.0)
        checkbox.padding = .zero
        checkbox.addTarget(self,
                         action: #selector(clickCheckbox(_:)),
                         for: .touchUpInside)
        return checkbox
    }()
  
    override func setupSubviews() {
        super.setupSubviews()
        self.leftView = checkbox
        self.leftViewSize = checkboxSize
        self.leftViewMargins = checkboxMargins
    }
    
    override func layoutLeftView() {
        super.layoutLeftView()
        let layoutFrame = layoutFrame()
        checkbox.centerY = layoutFrame.midY
    }

    override func checkTypeDidChange() {
        switch checkType {
        case .normal:
            checkbox.mode = .normal
        case .increase:
            checkbox.mode = .plus
        case .decrease:
            checkbox.mode = .minus
        }
    }
    
    override func priorityDidChange() {
        let color = priority.titleColor
        checkbox.normalColor = color
        checkbox.checkedColor = color
    }

    override func setCompleted(_ isCompleted: Bool, animated: Bool = false) {
        super.setCompleted(isCompleted, animated: animated)
        checkbox.setChecked(isCompleted, animated: animated)
    }

    /// 点击检查按钮
    @objc func clickCheckbox(_ button: UIButton) {
        didClickCheckbox?(checkbox)
    }
}
