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
    
    /// 布局类型（跟随主页当前布局）
    var layoutType: CountdownEventLayoutType = .list {
        didSet {
            listView.layoutType = layoutType
        }
    }
    
    /// 当前搜索文本
    private(set) var searchText: String?
    
    /// 无搜索结果占位视图提供者
    private let placeholderProvider = TPDefaultPlaceholderProvider()
    
    /// 搜索结果列表视图
    lazy var listView: CountdownEventListView = {
        let listView = CountdownEventListView(frame: .zero)
        listView.delegate = self
        listView.layoutType = layoutType
        listView.placeholderProvider = placeholderProvider
        listView.collectionView.keyboardAutoAdjustContentInset = true
        listView.collectionView.keyboardDismissMode = .interactive
        return listView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeholderProvider.emptyImage = resGetImage("placeholder_noSearchResult_80")
        view.addSubview(listView)
        listView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - 搜索
    /// 重新执行当前搜索
    func reloadSearchResults() {
        let searchText = self.searchText
        self.searchText = nil
        updateSearchResults(with: searchText)
    }
    
    /// 更新搜索结果
    func updateSearchResults(with searchText: String?) {
        /// 空文本视为无搜索条件
        var searchText = searchText?.whitespacesAndNewlinesTrimmedString
        if searchText?.count == 0 {
            searchText = nil
        }
        
        if self.searchText == searchText {
            return
        }
        
        self.searchText = searchText
        
        let group = CountdownEventGroup(identifier: "CountdownSearchResultGroup")
        group.events = searchEvents(containText: searchText)
        listView.groups = [group]
        listView.performUpdate()
    }
    
    /// 按名称搜索活动倒数日事项
    private func searchEvents(containText text: String?) -> [CountdownEvent] {
        guard let text = text, text.count > 0 else {
            return []
        }
        
        return CountdownRepository.getActiveEvents().filter { event in
            guard let name = event.name, name.count > 0 else {
                return false
            }
            
            return name.range(of: text, options: .caseInsensitive) != nil
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
