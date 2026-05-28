//
//  FocusHomeUserTimerContentViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/27.
//

import Foundation
import UIKit

class FocusHomeUserTimerContentViewController: TPViewController,
                                               FocusTrackerDelegate,
                                               FocusUserTimerListViewDelegate {
    
    /// 分页控制器
    weak var pageController: TPPageController?
    
    /// 添加按钮
    let addViewSize = CGSize(width: 50.0, height: 50.0)
    let addViewMargin = 20.0
    lazy var addView: TPAddView = {
        let view = TPAddView()
        view.didClickAdd = { [weak self] _ in
            self?.createNewTimer()
        }
        
        return view
    }()
    
    private let viewModel = FocusUserTimerViewModel()
    
    lazy var listView: FocusUserTimerListView = {
        let listView = FocusUserTimerListView(frame: .zero)
        listView.delegate = self
        listView.isReorderEnabled = true
        listView.placeholderProvider = self.viewModel.placeholderProvider
        return listView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.listView)
        self.view.addSubview(self.addView)
        self.listView.reloadData()
        self.viewModel.timersDidChange = { [weak self] change in
            self?.timersChanged(change)
        }
        
        self.viewModel.loadTimers()
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
    
    private func timersChanged(_ change: FocusUserTimerChange?) {
        let group = FocusTimerGroup(identifier: "UserTimerGroup")
        group.timers = self.viewModel.timers
        
        DispatchQueue.main.async {
            self.listView.groups = [group]
            self.listView.performUpdate()
            
            var revealTimer: FocusTimer?
            if let change = change {
                switch change {
                case .create(let timer), .update(let timer):
                    revealTimer = timer
                }
            }
            
            if let revealTimer = revealTimer {
                self.listView.revealItem(revealTimer, autoScroll: true)
            }
        }
    }
    
    private func createNewTimer() {
        let timers = listView.userTimers
        let timerController = FocusUserTimerController()
        timerController.createTimer(in: timers)
    }
    
    // MARK: - Public Methods
    public func revealTimer(_ timer: FocusTimer) {
        self.listView.revealItem(timer, autoScroll: true)
    }
    
    // MARK: -
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
    
    func focusUserTimerListViewHandleRefresh(_ listView: FocusUserTimerListView) {
        self.viewModel.setNeedsRefresh()
        self.viewModel.loadTimers()
    }
    
    // MARK: - FocusTrackerDelegate
    func focusTrackerStateDidChange(fromState: FocusTrackerState?, toState: FocusTrackerState) {
        self.listView.updateFocusingIndicator()
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
}
