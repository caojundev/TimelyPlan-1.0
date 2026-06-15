//
//  FocusArchivedTimerViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/29.
//

import Foundation

class FocusArchivedTimerViewModel: FocusUserTimerViewModel {
    
    override init() {
        super.init()
        
        self.placeholderProvider.emptyImage = resGetImage("archivedList_80")
        self.placeholderProvider.emptyTitle = resGetString("No Archived Timer")
    }

    override func fetchTimers(completion: @escaping ([FocusTimer]?) -> Void) {
        FocusRepository.fetchArchivedTimers(completion: completion)
    }
}
