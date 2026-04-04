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
    
    private let maximumContentHeight = 300.0
    
    private var editView: TodoQuickAddProgressEditContentView!
    
    override func setupSubviews() {
        super.setupSubviews()
        self.editView = TodoQuickAddProgressEditContentView()
        self.editView.backgroundColor = .secondarySystemBackground
        self.popoverView = self.editView
    }

    override var popoverContentSize: CGSize {
        var contentHeight = 240.0
        clampValue(&contentHeight, minimumContentHeight, maximumContentHeight)
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    func reloadData() {
        
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
