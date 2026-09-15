//
//  CountdownArchivedEventViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/15.
//

import Foundation

class CountdownArchivedEventViewModel: CountdownEventViewModel {
    
    override init() {
        super.init()
        
        self.placeholderProvider.emptyImage = resGetImage("archivedList_80")
        self.placeholderProvider.emptyTitle = resGetString("No Archived Countdown")
    }
    
    override func fetchEvents(completion: @escaping ([CountdownEvent]?) -> Void) {
        CountdownRepository.fetchArchivedEvents(completion: completion)
    }
}
