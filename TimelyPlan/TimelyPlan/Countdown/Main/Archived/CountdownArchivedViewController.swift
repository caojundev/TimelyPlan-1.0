//
//  CountdownArchivedViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/15.
//

import Foundation
import UIKit

class CountdownArchivedViewController: TPViewController,
                                       CountdownEventListViewDelegate {
    
    /// 已归档倒数日事项视图模型
    private let viewModel = CountdownArchivedEventViewModel()
    
    /// 倒数日事项列表视图
    lazy var listView: CountdownEventListView = {
        let listView = CountdownEventListView(frame: .zero)
        listView.delegate = self
        listView.placeholderProvider = viewModel.placeholderProvider
        return listView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.title = resGetString("Archived")
        self.view.addSubview(self.listView)
        self.listView.reloadData()
        
        self.viewModel.eventsDidChange = { [weak self] change in
            self?.eventsChanged(change)
        }
        self.viewModel.loadEvents()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.listView.frame = view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    /// 加载并刷新已归档倒数日事项
    private func reloadEvents() {
        let group = CountdownEventGroup(identifier: "ArchivedCountdownEventGroup")
        group.events = viewModel.events
        listView.groups = [group]
        listView.performUpdate()
    }
    
    /// 处理倒数日事项变更
    private func eventsChanged(_ change: CountdownEventChange?) {
        DispatchQueue.main.async { [weak self] in
            self?.reloadEvents()
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
        self.viewModel.setNeedsRefresh()
        self.viewModel.loadEvents()
    }
}
