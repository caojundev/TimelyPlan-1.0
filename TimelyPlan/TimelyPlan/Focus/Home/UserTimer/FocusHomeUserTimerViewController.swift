//
//  FocusHomeUserTimerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/27.
//

import Foundation
import UIKit

class FocusHomeUserTimerViewController: TPCollectionSectionsViewController,
                                            FocusTimerProcessorDelegate,
                                            TPCollectionDragInsertReorderDelegate,
                                            FocusSessionProcessorDelegate,
                                            FocusTrackerDelegate {
    
    weak var pageController: TPPageController?
    
    /// 添加按钮
    let addViewSize = CGSize(width: 50.0, height: 50.0)
    let addViewMargin = 20.0
    lazy var addView: TodoTaskAddView = {
        let view = TodoTaskAddView()
        view.didClickAdd = { [weak self] button in
            self?.clickAdd(button)
        }
        
        return view
    }()
        
    /// 占位视图
    lazy var placeholderView: TPDefaultPlaceholderView = {
        let view = TPDefaultPlaceholderView()
        view.isBorderHidden = true
        view.image = resGetImage("placeholder_noSearchResult_80")
        return view
    }()
    
    lazy var userTimerSectionController: FocusHomeUserTimerSectionController = {
        let sectionController = FocusHomeUserTimerSectionController()
        return sectionController
    }()
    
    private var reorder: TPCollectionDragInsertReorder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.addView)
        
        self.setupReorder()
        self.collectionView.placeholderView = placeholderView
        self.sectionControllers = [userTimerSectionController]
        self.adapter.reloadData()
        focus.addUpdaterDelegate(self)
        FocusTracker.shared.addDelegate(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addAppLifeCycleNotification()
        userTimerSectionController.isDisplaying = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeAppLifeCycleNotification()
        userTimerSectionController.isDisplaying = false
    }
    
    override func appDidBecomeActive() {
        userTimerSectionController.isDisplaying = true
    }
    
    override func appDidEnterBackground() {
        userTimerSectionController.isDisplaying = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeAreaFrame()
        addView.size = addViewSize
        addView.bottom = layoutFrame.maxY - addViewMargin
        addView.right = layoutFrame.maxX - addViewMargin
    
        let insetBottom = layoutFrame.maxY - addView.top
        collectionView.contentInset = UIEdgeInsets(top: 0.0,
                                                   left: 0.0,
                                                   bottom: insetBottom,
                                                   right: 0.0)
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    /// 初始化排序管理器
    private func setupReorder() {
        let reorder = TPCollectionDragInsertReorder(collectionView: self.collectionView)
        reorder.indicatorBackColor = Color(0xFFFFFF, 0.1)
        reorder.isEnabled = true
        reorder.delegate = self
        self.reorder = reorder
    }
    
    // MARK: - Event Response
    @objc func clickAdd(_ button: UIButton) {
        let timers = userTimerSectionController.timers
        let timerController = FocusUserTimerController()
        timerController.createTimer(in: timers)
    }
    
    
    // MARK: - FocusTrackerDelegate
    func focusTrackerStateDidChange(fromState: FocusTrackerState?, toState: FocusTrackerState) {
        userTimerSectionController.updateFocusingIndicator()
    }
    
    // MARK: - FocusTimerProcessorDelegate
    func didCreateFocusTimer(_ timer: FocusTimer) {
        self.adapter.performUpdate { _ in
            self.revealTimer(timer)
        }
    }
    
    func didChangeArchivedState(_ isArchived: Bool, for timer: FocusTimer) {
        self.adapter.performUpdate()
    }
    
    func didUpdateFocusTimer(_ timer: FocusTimer) {
        self.adapter.reloadCell(forItem: timer, focusAnimated: true)
    }
    
    func didDeleteFocusTimer(_ timer: FocusTimer) {
        self.adapter.performUpdate()
    }
    
    func didMoveFocusTimerToTop(_ timer: FocusTimer) {
        self.adapter.performUpdate()
    }
    
    func didReorderFocusTimer(in timers: [FocusTimer], fromIndex: Int, toIndex: Int) {
        
    }
    
    // MARK: - FocusSessionProcessorDelegate
    func didAddFocusSession(_ session: FocusSession, with record: FocusRecord) {
        if session.isManual {
            /// 手动添加的会话，弹出添加成功消息
            let message = resGetString("Add focus record successfully")
            TPFeedbackQueue.common.postFeedback(text: message, position: .top)
        }
        
        guard isDisplaying, let timer = record.timer as? FocusTimer else {
            return
        }
        
        revealTimer(timer)
    }
    
    func didUpdateFocusSession(_ session: FocusSession) {
        
    }
    
    func didDeleteFocusSession(_ session: FocusSession) {
        
    }
    
    // MARK: - TPCollectionDragInsertReorderDelegate
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                canInsertItemTo targetIndexPath: IndexPath,
                                     from sourceIndexPath: IndexPath) -> Bool {
        return true
    }

    
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                inserItemTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                     depth: Int) -> IndexPath? {
        let timers = userTimerSectionController.timers
        let movedTimer = timers[sourceIndexPath.item]
        focus.reorderTimer(in: timers, fromIndex: sourceIndexPath.item, toIndex: targetIndexPath.item)
        adapter.performUpdate() /// 更新列表
        if let index = userTimerSectionController.index(of: movedTimer) {
            return IndexPath(item: index, section: userTimerSectionController.section)
        }
        
        return nil
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
        self.adapter.scrollToItem(timer, at: .centeredVertically, animated: true) { _ in
            self.adapter.commitFocusAnimation(for: timer)
        }
    }
}
