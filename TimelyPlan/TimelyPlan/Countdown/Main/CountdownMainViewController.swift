//
//  CountdownMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/13.
//

import Foundation
import UIKit

class CountdownMainViewController: TPContainerViewController,
                                    TPSidebarContent,
                                    UISearchBarDelegate {
    
    struct Config {
        /// 搜索栏高度
        static let searchBarHeight = 60.0
        /// 搜索栏边界间距
        static let searchBarEdgeMargin = 10.0
    }
    
    /// 侧边栏控制器
    var sidebarController: SidebarController?
    
    /// 更多菜单按钮
    private lazy var moreBarButtonItem: CountdownMoreBarButtonItem = {
        let item = CountdownMoreBarButtonItem()
        item.layoutType = layoutType
        item.didSelectType = { [weak self] type in
            self?.performMoreMenuAction(type)
        }
        
        return item
    }()
    
    /// 当前布局类型
    private var layoutType: CountdownLayoutType = .list
    
    /// 搜索栏
    lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.delegate = self
        bar.placeholder = resGetString("Search Countdown")
        bar.barTintColor = .clear
        bar.tintColor = resGetColor(.title)
        bar.backgroundImage = UIImage()
        return bar
    }()
    
    /// 倒数日事项列表内容
    lazy var listContentViewController: CountdownEventListViewController = {
        let viewController = CountdownEventListViewController()
        viewController.layoutType = layoutType
        return viewController
    }()
    
    /// 搜索结果视图控制器
    private var searchResultViewController: CountdownEventSearchResultViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Countdown")
        navigationItem.leftBarButtonItem = sidebarController?.newMenuButtonItem()
        navigationItem.rightBarButtonItems = [moreBarButtonItem]
        view.addSubview(searchBar)
        setContentViewController(listContentViewController)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutSearchBar()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    /// 内容视图区域（搜索栏下方）
    override func contentViewFrame() -> CGRect {
        var frame = view.safeAreaFrame()
        frame.origin.y += Config.searchBarHeight
        frame.size.height -= Config.searchBarHeight
        
        return frame
    }
    
    // MARK: - 搜索栏
    private func layoutSearchBar() {
        let layoutFrame = view.safeAreaFrame()
        let searchBarWidth = view.width - 2 * Config.searchBarEdgeMargin
        self.searchBar.width = min(CountdownConfig.eventListContentMaxWidth, searchBarWidth)
        self.searchBar.height = Config.searchBarHeight
        self.searchBar.top = layoutFrame.minY
        self.searchBar.alignHorizontalCenter()
    }
    
    // MARK: - 搜索
    /// 展示搜索结果
    private func showSearchResults(with searchText: String?) {
        if searchResultViewController == nil {
            let viewController = CountdownEventSearchResultViewController()
            viewController.layoutType = layoutType
            self.searchResultViewController = viewController
        }
        
        if let searchResultViewController = searchResultViewController {
            setContentViewController(searchResultViewController)
            searchResultViewController.updateSearchResults(with: searchText)
        }
    }
    
    /// 结束搜索，回到事项列表
    private func endSearchResults() {
        searchResultViewController = nil
        setContentViewController(listContentViewController)
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        showSearchResults(with: searchBar.text)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let searchTextCount = searchBar.text?.count ?? 0
        if searchTextCount == 0 {
            searchBarCancelButtonClicked(searchBar)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        endSearchResults()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResultViewController?.updateSearchResults(with: searchText)
    }
    
    // MARK: - Event Response
    /// 切换列表 / 网格布局
    private func toggleLayout() {
        TPImpactFeedback.impactWithLightStyle()
        
        layoutType = layoutType.toggled
        moreBarButtonItem.layoutType = layoutType
        listContentViewController.layoutType = layoutType
        searchResultViewController?.layoutType = layoutType
    }
    
    /// 执行更多菜单操作
    func performMoreMenuAction(_ type: CountdownMoreMenuType) {
        switch type {
        case .layout:
            toggleLayout()
        case .archived:
            CountdownPresenter.showArchived()
            break
        }
    }
}
