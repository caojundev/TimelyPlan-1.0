//
//  TodoTaskSectionSelectPopoverView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/6.
//

import Foundation
import UIKit

class TodoTaskSectionSelectPopoverView: TPBasePopoverView {
    
    var didSelectSection: ((TodoSection) -> Void)?

    /// 选中列表
    var selectedSection: TodoSection? {
        didSet {
//            selectView.list = selectedList
        }
    }
    
    var handleBeforeDismiss: Bool = true
    
    private let contentWidth = 280.0
    
    private let minimumContentHeight = 180.0
    
    private let maximumContentHeight = 360.0
    
    private var selectView: TodoTaskSectionSelectView!
    
    override func setupSubviews() {
        super.setupSubviews()
        self.selectView = TodoTaskSectionSelectView()
        self.selectView.didSelectSection = { [weak self] section in
            self?.selectSection(section)
        }
        
        self.popoverView = self.selectView
    }

    override var popoverContentSize: CGSize {
        var contentHeight = selectView.contentSize.height
        clampValue(&contentHeight, minimumContentHeight, maximumContentHeight)
        return CGSize(width: contentWidth, height: contentHeight)
    }
    

    // MARK: - 选中菜单项
    private func selectSection(_ section: TodoSection) {
        if handleBeforeDismiss {
            didSelectSection?(section)
            hide(animated: isHideWithAnimation)
        } else {
            hide(animated: isHideWithAnimation) {
                self.didSelectSection?(section)
            }
        }
    }
}
