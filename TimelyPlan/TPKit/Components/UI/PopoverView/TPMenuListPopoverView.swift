//
//  TPMenuListPopoverView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/25.
//

import Foundation
import UIKit

class TPMenuListPopoverView: TPBasePopoverView {
    
    /// 选中菜单动作回调
    var didSelectMenuAction: ((TPMenuAction) -> Void)?
    
    var menuItems: [TPMenuItem]? {
        didSet {
            guard menuItems != oldValue else {
                return
            }
            
            reloadData()
        }
    }
    
    private let menuListView = TPMenuListView()
    
    override func setupSubviews() {
        super.setupSubviews()
        self.popoverView = menuListView
        self.menuListView.didSelectMenuAction = { [weak self] action in
            self?.selectMenuAction(action)
        }
    }
    
    func reloadData() {
        menuListView.menuItems = menuItems
        menuListView.reloadData()
        updateContentSizeIfNeeded()
    }
    
    override var popoverContentSize: CGSize {
        let contentSize = self.menuListView.contentSize
        return CGSize(width: 200.0, height: contentSize.height)
    }
    
    // MARK: - 选中菜单项
    func selectMenuAction(_ action: TPMenuAction) {
        if action.handleBeforeDismiss {
            self.didSelectMenuAction?(action)
            action.handler?(action)
            hide(animated: isHideWithAnimation)
        } else {
            hide(animated: isHideWithAnimation) {
                self.didSelectMenuAction?(action)
                action.handler?(action)
            }
        }
    }
}
