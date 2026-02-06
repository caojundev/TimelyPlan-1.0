//
//  SidebarController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/3/16.
//

import Foundation

protocol TFSidebarContent: AnyObject {
    
    /// 侧边栏管理器
    var sidebarController: SidebarController? {get set}
}

class SidebarController {
    
    /// 侧边栏视图控制器
    weak var sidebarViewController: TPSidebarViewController?
    
    /// 显示侧边栏
    func showSidebar(animated: Bool = true) {
        TPImpactFeedback.impactWithLightStyle()
        sidebarViewController?.setExpand(true, animated: animated)
    }
    
    /// 隐藏侧边栏
    func hideSidebar(animated: Bool = true) {
        TPImpactFeedback.impactWithLightStyle()
        sidebarViewController?.setExpand(false, animated: animated)
    }
    
    /// 创建新侧边栏菜单按钮
    func newMenuButtonItem() -> UIBarButtonItem {
        let image = resGetImage("SideMenu")
        let buttonItem = UIBarButtonItem(image: image,
                                         style: .plain,
                                         target: self,
                                         action: #selector(clickMenu(_:)))
        return buttonItem
    }
    
    /// 点击侧边栏按钮
    @objc private func clickMenu(_ buttonItem: UIBarButtonItem) {
        showSidebar()
    }
}
