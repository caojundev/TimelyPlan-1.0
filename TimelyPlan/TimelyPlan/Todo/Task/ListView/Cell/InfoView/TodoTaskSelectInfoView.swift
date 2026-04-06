//
//  TodoTaskSelectInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/13.
//

import Foundation
import UIKit

class TodoTaskSelectInfoView: TodoTaskBaseInfoView {
    
    var isSelected: Bool {
        get {
            return checkbox.isChecked
        }
        
        set {
            checkbox.setChecked(newValue)
        }
    }
    
    /// 选中按钮
    private let checkboxSize = CGSize(width: 20.0, height: 20.0)
    private let checkboxMargins = UIEdgeInsets(right: 15.0)
    private(set) lazy var checkbox: TPCircularCheckbox = {
        let checkbox = TPCircularCheckbox()
        checkbox.isUserInteractionEnabled = false
        checkbox.padding = .zero
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
    
    override func priorityDidChange() {
        let color = priority.titleColor
        checkbox.innerColor = color
        checkbox.outerColor = color
    }
    
    func setSelected(_ isSelected: Bool, animated: Bool = false) {
        checkbox.setChecked(isSelected, animated: animated)
    }
}

