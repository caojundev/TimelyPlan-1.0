//
//  SideMenuViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/11.
//

import Foundation

protocol SideMenuViewControllerDelegate: AnyObject {

    /// 选中菜单回调
    func sideMenuViewController(_ vc: SideMenuViewController, didSelect menuType: SideMenuType)

    /// 隐藏侧边菜单栏
    func sideMenuViewControllerHideSideMenu(_ vc: SideMenuViewController)
    
}

class SideMenuViewController: TPTableViewController,
                                TPTableViewAdapterDataSource,
                                TPTableViewAdapterDelegate {
    
    weak var delegate: SideMenuViewControllerDelegate?
    
    /// 当前选中菜单类型
    var selectedMenuType: SideMenuType = .focus
    
    /// 我的一天
    let myDayMenuItem: TPMenuItem = TPMenuItem.item(with: [SideMenuType.myDay])

    /// 任务模块
    lazy var taskMenuItem: TPMenuItem = {
        let types: [SideMenuType] = [.todo, .quadrants]
        let menuItem = TPMenuItem.item(with: types)
        return menuItem
    }()
    
    /// 专注
    let focusMenuItem: TPMenuItem = TPMenuItem.item(with: [SideMenuType.focus])

    /// 日历
    let calendarMenuItem: TPMenuItem = TPMenuItem.item(with: [SideMenuType.calendar])

    /// 设置
    let settingMenuItem: TPMenuItem = TPMenuItem.item(with: [SideMenuType.settings])

    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.cellStyle.backgroundColor = resGetColor(.sidebar, .background)
        adapter.cellStyle.selectedBackgroundColor = resGetColor(.sidebar, .cell, .background, .selected)
        adapter.dataSource = self
        adapter.delegate = self
        adapter.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var inset = UIEdgeInsets.zero
        inset.top = max(view.safeHeight - tableView.contentSize.height, 0.0)
        self.tableView.contentInset = inset
    }

    override func themeDidChange() {
        super.themeDidChange()
        tableView.backgroundColor = resGetColor(.sidebar, .background)
    }

    // MARK: - dataSource
    func sectionObjects(for adapter: TPTableViewAdapter) -> [ListDiffable]? {
        return [myDayMenuItem,
                taskMenuItem,
                calendarMenuItem,
                focusMenuItem,
                settingMenuItem]
    }
    
    func adapter(_ adapter: TPTableViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        let menuItem = sectionObject as! TPMenuItem
        return menuItem.actions
    }
    
    // MARK: - Delegate
    func adapter(_ adapter: TPTableViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return SideMenuCell.self
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didDequeCell cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! SideMenuCell
        cell.menuAction = adapter.item(at: indexPath) as? TPMenuAction
    }
    
    func adapter(_ adapter: TPTableViewAdapter, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func adapter(_ adapter: TPTableViewAdapter, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 10.0
        }
        
        return 0.0
    }
    
    func adapter(_ adapter: TPTableViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        if section > 0 {
            return TPSeparatorTableHeaderFooterView.self
        }
        
        return nil
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didDequeHeader headerView: UITableViewHeaderFooterView, inSection section: Int) {
        if let headerView = headerView as? TPSeparatorTableHeaderFooterView {
            headerView.lineColor = resGetColor(.sidebar, .separator)
        }
    }
    
    func adapter(_ adapter: TPTableViewAdapter, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        guard let menuType = menuType(at: indexPath) else {
            return false
        }

        return menuType == selectedMenuType
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didSelectRowAt indexPath: IndexPath) {
        guard let menuType = menuType(at: indexPath) else {
            return
        }
        
        if selectedMenuType != menuType {
            selectedMenuType = menuType
            delegate?.sideMenuViewController(self, didSelect: menuType)
            adapter.updateCheckmarks(animated: true)
        } else {
            
            /// 关闭侧边栏
            delegate?.sideMenuViewControllerHideSideMenu(self)
        }
    }
    
    func menuType(at indexPath: IndexPath) -> SideMenuType? {
        guard let menuAction = adapter.item(at: indexPath) as? TPMenuAction,
              let menuType = SideMenuType(rawValue: menuAction.identifier) else {
            return nil
        }
        
        return menuType
    }
    
}
