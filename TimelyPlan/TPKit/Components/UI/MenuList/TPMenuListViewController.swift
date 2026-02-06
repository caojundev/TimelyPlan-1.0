//
//  TPMenuListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/17.
//

import Foundation
import FluentDarkModeKit

class TPMenuListViewController: TPViewController {
    
    /// 选中菜单动作回调
    var didSelectMenuAction: ((TPMenuAction) -> Void)?
    
    /// 菜单内容宽度
    var menuContentWidth: CGFloat = 180.0

    /// 菜单内容最大高度
    var maxMenuContentHeight: CGFloat = 600.0

    /// 菜单条目数组
    var menuItems: [TPMenuItem]? {
        get {
            return listView.menuItems
        }
        
        set {
            listView.menuItems = newValue
        }
    }
    
    private(set) var listView = TPMenuListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listView.tintColor = resGetColor(.title)
        listView.didSelectMenuAction = { [weak self] action in
            self?.selectMenuAction(action)
        }
        
        view.addSubview(listView)
        listView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
        updatePopoverContentSize()
    }
    
    override var popoverContentSize: CGSize {
        var contentSize = listView.contentSize
        contentSize.width = menuContentWidth
        contentSize.height = min(contentSize.height, maxMenuContentHeight)
        return contentSize
    }
    
    public func selectMenuAction(_ action: TPMenuAction) {
        if action.handleBeforeDismiss {
            didSelectMenuAction?(action)
            action.handler?(action)
            dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true) {
                self.didSelectMenuAction?(action)
                action.handler?(action)
            }
        }
    }
    
    public func reloadData() {
        listView.reloadData()
    }
}
