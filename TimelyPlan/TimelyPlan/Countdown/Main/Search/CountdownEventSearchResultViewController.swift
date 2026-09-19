//
//  CountdownEventSearchResultViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/17.
//

import Foundation
import UIKit

/// 倒数日事项搜索结果视图控制器
class CountdownEventSearchResultViewController: TPViewController,
                                                CountdownEventListViewDelegate {
    
    /// 倒数日事项搜索视图模型
    private let viewModel = CountdownEventSearchViewModel()
    
    /// 布局类型（跟随主页当前布局）
    var layoutType: CountdownLayoutType = .list {
        didSet {
            listView.layoutType = layoutType
        }
    }
    
    /// 无搜索结果占位视图提供者
    private let placeholderProvider = TPDefaultPlaceholderProvider()
    
    /// 搜索结果列表视图
    lazy var listView: CountdownEventSearchResultListView = {
        let listView = CountdownEventSearchResultListView(frame: .zero)
        listView.delegate = self
        listView.layoutType = layoutType
        listView.collectionView.addKeyboardNotification()
        listView.collectionView.keyboardAutoAdjustContentInset = true
        listView.placeholderProvider = placeholderProvider
        return listView
    }()
    
    deinit {
        listView.collectionView.removeKeyboardNotification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeholderProvider.emptyImage = resGetImage("placeholder_noSearchResult_80")
        view.addSubview(listView)
        listView.reloadData()
        
        viewModel.eventsDidChange = { [weak self] _ in
            self?.updateListView()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - 搜索
    /// 更新搜索结果
    func updateSearchResults(with searchText: String?) {
        viewModel.updateSearchText(searchText)
    }
    
    /// 重新执行当前搜索
    func reloadSearchResults() {
        viewModel.setNeedsRefresh()
        viewModel.loadEvents()
    }
    
    /// 更新列表视图
    private func updateListView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.listView.searchText = self.viewModel.searchText
            self.listView.groups = self.viewModel.groups
            self.listView.performUpdate()
        }
    }
    
    // MARK: - CountdownEventListViewDelegate
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        if let event = collectionView.item(at: indexPath) as? CountdownEvent {
            CountdownPresenter.editEvent(event)
        }
    }
    
    func countdownEventListViewHandleRefresh(_ listView: CountdownEventListView) {
        reloadSearchResults()
    }
}
