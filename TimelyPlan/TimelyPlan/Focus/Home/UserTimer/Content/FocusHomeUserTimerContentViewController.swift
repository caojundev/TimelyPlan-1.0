//
//  FocusHomeUserTimerContentViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/27.
//

import Foundation
import UIKit

class FocusHomeUserTimerContentViewController: TPViewController,
                                               FocusTimerProcessorDelegate,
                                               FocusSessionProcessorDelegate,
                                               FocusTrackerDelegate,
                                               FocusUserTimerListViewDelegate {
    
    /// 分页控制器
    weak var pageController: TPPageController?
    
    /// 添加按钮
    let addViewSize = CGSize(width: 50.0, height: 50.0)
    let addViewMargin = 20.0
    lazy var addView: TodoTaskAddView = {
        let view = TodoTaskAddView()
        view.didClickAdd = { [weak self] _ in
            self?.createNewTimer()
        }
        
        return view
    }()
    
    lazy var listView: FocusUserTimerListView = {
        let listView = FocusUserTimerListView(frame: .zero)
        listView.delegate = self
        listView.isReorderEnabled = true
        listView.listPlaceholderProvider.emptyImage = resGetImage("focus_placeholder_noTimer_80")
        listView.listPlaceholderProvider.emptyTitle = resGetString("No Timer")
        return listView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.listView)
        self.view.addSubview(self.addView)
        self.listView.asyncReloadData()
        
        focus.addUpdater(self)
        FocusTracker.shared.addDelegate(self)
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeAreaFrame()
        self.addView.size = addViewSize
        self.addView.bottom = layoutFrame.maxY - addViewMargin
        self.addView.right = layoutFrame.maxX - addViewMargin
    
        self.listView.frame = view.bounds
        let insetBottom = layoutFrame.maxY - addView.top
        self.listView.contentInset = UIEdgeInsets(top: 0.0,
                                                   left: 0.0,
                                                   bottom: insetBottom,
                                                   right: 0.0)
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func createNewTimer() {
        let timers = listView.userTimers
        let timerController = FocusUserTimerController()
        timerController.createTimer(in: timers)
    }
    
    // MARK: -
    
    func loadableGroupCollectionView(_ collectionView: TPLoadableGroupCollectionView, forceRefresh: Bool, fetchTaskGroups completion: @escaping ([GroupRepresentable]?) -> Void) {
        focus.fetchActiveTimers { timers in
            guard let timers = timers, timers.count > 0 else {
                completion(nil)
                return
            }

            let group = FocusTimerGroup(identifier: "HomeUserTimerGroup")
            group.timers = timers
            completion([group])
        }
    }
  
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        if let timer = collectionView.item(at: indexPath) as? FocusTimer {
            FocusPresenter.startFocus(with: timer)
        }
    }
    
    func focusUserTimerListView(_ listView: FocusUserTimerListView, moveItemAt sourceIndexPath: IndexPath, to targetIndexPath: IndexPath) {
        guard let timers = listView.items(for: targetIndexPath.section) as? [FocusTimer] else {
            return
        }
        
        focus.reorderTimer(in: timers, fromIndex: sourceIndexPath.item, toIndex: targetIndexPath.item)
    }
    
    // MARK: - FocusTrackerDelegate
    func focusTrackerStateDidChange(fromState: FocusTrackerState?, toState: FocusTrackerState) {
        self.listView.updateFocusingIndicator()
    }
    
    // MARK: - FocusTimerProcessorDelegate
    func didCreateFocusTimer(_ timer: FocusTimer) {
        self.listView.asyncPerformUpdate { [weak self] _ in
            self?.revealTimer(timer)
        }
    }
    
    func didChangeArchivedState(_ isArchived: Bool, for timer: FocusTimer) {
        self.listView.asyncPerformUpdate()
    }
    
    func didUpdateFocusTimer(_ timer: FocusTimer) {
        self.listView.asyncPerformUpdate { [weak self] _ in
            self?.revealTimer(timer)
        }
    }
    
    func didDeleteFocusTimer(_ timer: FocusTimer) {
        self.listView.asyncPerformUpdate()
    }
    
    func didMoveFocusTimerToTop(_ timer: FocusTimer) {
        self.listView.asyncPerformUpdate()
    }
    
    func didReorderFocusTimer(in timers: [FocusTimer], fromIndex: Int, toIndex: Int) {
        /// 无需操作
    }
    
    // MARK: - FocusSessionProcessorDelegate
    func didAddFocusSessions(_ sessions: [FocusSession]) {
        guard sessions.count > 0 else {
            return
        }
        
        let format: String
        if sessions.count > 1 {
            format = resGetString("%ld focus records added successfully")
        } else {
            format = resGetString("%ld focus record added successfully")
        }
        
        let message = String(format: format, sessions.count)
        TPFeedbackQueue.common.postFeedback(text: message, position: .top)
    }
    
    func didUpdateFocusSession(_ session: FocusSession) {
        
    }
    
    func didDeleteFocusSession(_ session: FocusSession) {
        
    }
    
    // MARK: - Helpers
    /// 判断当前是否为正在显示的视图控制器
    var isDisplaying: Bool {
        var isCurrent = false
        if let pageController = pageController {
            isCurrent = pageController.selectedPageIndex == FocusMainMenuType.timer.rawValue
        }
        
        return isCurrent
    }
    
    // MARK: - Public Methods
    public func revealTimer(_ timer: FocusTimer) {
        self.listView.revealItem(timer)
    }
}
