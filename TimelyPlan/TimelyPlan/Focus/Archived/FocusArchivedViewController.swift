//
//  FocusArchivedViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/6.
//

import Foundation

class FocusArchivedViewController: TPViewController,
                                   FocusUserTimerListViewDelegate,
                                   FocusTimerProcessorDelegate,
                                   FocusTrackerDelegate {
    
    lazy var listView: FocusUserTimerListView = {
        let listView = FocusUserTimerListView(frame: .zero)
        listView.delegate = self
        listView.listPlaceholderProvider.emptyImage = resGetImage("archivedList_80")
        listView.listPlaceholderProvider.emptyTitle = resGetString("No Archived Timer")
        return listView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.title = resGetString("Archived")
        self.view.addSubview(self.listView)
        self.listView.asyncReloadData()
        focus.addUpdater(self, for: [.timer])
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
    
    // MARK: - FocusTrackerDelegate
    func focusTrackerStateDidChange(fromState: FocusTrackerState?, toState: FocusTrackerState) {
        self.listView.updateFocusingIndicator()
    }
    
    // MARK: - FocusUserTimerListViewDelegate
    func loadableGroupCollectionView(_ collectionView: TPLoadableGroupCollectionView, forceRefresh: Bool, fetchTaskGroups completion: @escaping ([GroupRepresentable]?) -> Void) {
        focus.fetchArchivedTimers { timers in
            guard let timers = timers, timers.count > 0 else {
                completion(nil)
                return
            }

            let group = FocusTimerGroup(identifier: "ArchivedTimerGroup")
            group.timers = timers
            completion([group])
        }
    }
  
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        if let timer = collectionView.item(at: indexPath) as? FocusTimer {
            FocusPresenter.showStatistics(for: timer)
        }
    }

    // MARK: - FocusTimerProcessorDelegate
    func didChangeArchivedState(_ isArchived: Bool, for timer: FocusTimer) {
        self.listView.asyncPerformUpdate()
    }
    
    func didDeleteFocusTimer(_ timer: FocusTimer) {
        self.listView.asyncPerformUpdate()
    }
}
