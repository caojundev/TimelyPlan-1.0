//
//  FocusArchivedViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/6.
//

import Foundation

class FocusArchivedViewController: TPViewController,
                                   FocusUserTimerListViewDelegate,
                                   FocusTrackerDelegate {
    
    lazy var listView: FocusUserTimerListView = {
        let listView = FocusUserTimerListView(frame: .zero)
        listView.delegate = self
        listView.placeholderProvider = self.viewModel.placeholderProvider
        return listView
    }()
    
    private let viewModel = FocusArchivedTimerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.title = resGetString("Archived")
        self.view.addSubview(self.listView)
        self.listView.reloadData()
        self.viewModel.timersDidChange = { [weak self] change in
            self?.timersChanged(change)
        }
        
        self.viewModel.loadTimers()
        FocusTracker.shared.addDelegate(self)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.addAppLifeCycleNotification()
        self.listView.isDisplaying = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeAppLifeCycleNotification()
        self.listView.isDisplaying = false
    }
    
    override func appDidBecomeActive() {
        self.listView.isDisplaying = true
    }
    
    override func appDidEnterBackground() {
        self.listView.isDisplaying = false
    }
    
    private func timersChanged(_ change: FocusUserTimerChange?) {
        let group = FocusTimerGroup(identifier: "HomeUserTimerGroup")
        group.timers = self.viewModel.timers
        self.listView.groups = [group]
        self.listView.performUpdate()
    }
    
    // MARK: - FocusTrackerDelegate
    func focusTrackerStateDidChange(fromState: FocusTrackerState?, toState: FocusTrackerState) {
        self.listView.updateFocusingIndicator()
    }
    
    // MARK: - FocusUserTimerListViewDelegate
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        if let timer = collectionView.item(at: indexPath) as? FocusTimer {
            FocusPresenter.showStatistics(for: timer)
        }
    }
    
    func focusUserTimerListViewHandleRefresh(_ listView: FocusUserTimerListView) {
        self.viewModel.setNeedsRefresh()
        self.viewModel.loadTimers()
    }
}
