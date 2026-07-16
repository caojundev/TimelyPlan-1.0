//
//  FocusUserTimerViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/29.
//

import Foundation

enum FocusUserTimerChange {
    case create(FocusTimer)
    case update(FocusTimer)
}

class FocusUserTimerViewModel: FocusTimerProcessorDelegate {
    
    private(set) var timers: [FocusTimer]?
    
    /// 计时器改变
    var timersDidChange: ((FocusUserTimerChange?) -> Void)?
    
    private(set) var state: TPListLoadingState = .initialLoading {
        didSet {
            self.placeholderProvider.state = state
        }
    }
    
    private var needsRefresh = true

    private let requestManager = TPRequestManager()
    
    var placeholderProvider = TPLoadableListPlaceholderProvider()
    
    init() {
        self.placeholderProvider.state = self.state
        self.placeholderProvider.emptyImage = resGetImage("focus_placeholder_noTimer_80")
        self.placeholderProvider.emptyTitle = resGetString("No Timer")
        FocusRepository.addUpdater(self)
    }

    func setNeedsRefresh(_ refresh: Bool = true) {
        self.needsRefresh = refresh
    }

    // MARK: -
    func loadTimers(with change: FocusUserTimerChange? = nil, completion: (() -> Void)? = nil) {
        let change = change
        let requestID = requestManager.executeRequest()
        loadTimersIfNeeded {[weak self] timers in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                completion?()
                return
            }

            self.timers = timers
            self.needsRefresh = false
            self.state = .loaded
            self.timersDidChange?(change)
            completion?()
        }
    }
    
    private func loadTimersIfNeeded(completion: @escaping ([FocusTimer]?) -> Void) {
        guard self.needsRefresh else {
            completion(self.timers)
            return
        }
        
        fetchTimers(completion: completion)
    }

    func fetchTimers(completion: @escaping ([FocusTimer]?) -> Void) {
        FocusRepository.fetchActiveTimers(completion: completion)
    }
    
    // MARK: - FocusTimerProcessorDelegate
    func didChangeRemoteFocusTimer(with results: EntityChangeResults<FocusTimer>?) {
        setNeedsRefresh()
        loadTimers()
    }
    
    func didCreateFocusTimer(_ timer: FocusTimer) {
        setNeedsRefresh()
        loadTimers(with: .create(timer))
    }
    
    func didChangeArchivedState(_ isArchived: Bool, for timer: FocusTimer) {
        setNeedsRefresh()
        loadTimers(with: .update(timer))
    }
    
    func didUpdateFocusTimer(_ timer: FocusTimer, with editingTimer: FocusEditingTimer) {
        setNeedsRefresh()
        loadTimers(with: .update(timer))
    }
    
    func didDeleteFocusTimer(_ timer: FocusTimer) {
        setNeedsRefresh()
        loadTimers()
    }
    
    func didMoveFocusTimerToTop(_ timer: FocusTimer) {
        setNeedsRefresh()
        loadTimers()
    }
    
    func didReorderFocusTimer(in timers: [FocusTimer], fromIndex: Int, toIndex: Int) {
  
    }
}
