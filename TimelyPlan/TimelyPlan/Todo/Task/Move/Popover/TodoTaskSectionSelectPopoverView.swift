//
//  TodoTaskSectionSelectPopoverView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/6.
//

import Foundation
import UIKit

class TodoTaskSectionSelectPopoverView: TPBasePopoverView {
    
    var didSelectSection: ((TodoSectionFeature) -> Void)?
    
    var handleBeforeDismiss: Bool = true
    
    private let contentWidth = 280.0
    
    private let minimumContentHeight = 180.0
    
    private let maximumContentHeight = 360.0
    
    private var selectView: TodoTaskSectionSelectView
    
    init(selectedSection: TodoSectionFeature) {
        self.selectView = TodoTaskSectionSelectView(selectedSection: selectedSection)
        super.init(frame: .zero)
        self.selectView.didSelectSection = { [weak self] section in
            self?.selectSection(section)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        self.popoverView = self.selectView
    }

    override var popoverContentSize: CGSize {
        var contentHeight = selectView.contentSize.height
        clampValue(&contentHeight, minimumContentHeight, maximumContentHeight)
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    // MARK: - 选中菜单项
    private func selectSection(_ section: TodoSectionFeature) {
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
