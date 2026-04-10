//
//  TodoQuickAddProgressEditView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/4.
//

import Foundation
import UIKit

class TodoQuickAddProgressEditPopoverView: TPBasePopoverView {
    
    var handleBeforeDismiss: Bool = true
    
    private let contentWidth = 260.0
    
    private let minimumContentHeight = 100.0
    
    private let maximumContentHeight = 360.0
    
    private var editView: TodoQuickAddProgressEditContentView!

    var progressValueChanged: ((TodoEditProgress) -> Void)? {
        get {
            return self.editView.progressValueChanged
        }
        
        set {
            self.editView.progressValueChanged = newValue
        }
    }
    
    init(progress: TodoEditProgress? = nil) {
        self.editView = TodoQuickAddProgressEditContentView(progress: progress)
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        self.editView.backgroundColor = .secondarySystemBackground
        self.popoverView = self.editView
    }

    override var popoverContentSize: CGSize {
        var contentHeight = 250.0
        clampValue(&contentHeight, minimumContentHeight, maximumContentHeight)
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    // MARK: - 选中菜单项
    private func selectList(_ list: TodoListRepresentable?) {
        if handleBeforeDismiss {
            hide(animated: isHideWithAnimation)
        } else {
            hide(animated: isHideWithAnimation) {
                
            }
        }
    }
}
