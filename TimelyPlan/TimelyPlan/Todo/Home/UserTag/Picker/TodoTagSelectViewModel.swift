//
//  TodoTagSelectViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/5.
//

import Foundation

class TodoTagSelectViewModel: NSObject,
                              TodoTagProcessorDelegate {

    private(set) var tags: [TodoTag]?
    
    private(set) var isLoading: Bool = false
    
    private(set) var state: TPListLoadingState = .initialLoading
    
    private let requestManager = TPRequestManager()
    
    var onLoadTags: (() -> Void)?
    
    var onCreateTag: ((TodoTag) -> Void)?
    
    override init() {
        super.init()
        todo.addUpdater(self, for: [.tag])
    }
    
    func loadData() {
        loadTags {[weak self] success in
            guard success else { return }
            self?.onLoadTags?()
        }
    }
    
    /// 加载标签
    private func loadTags(completion:@escaping(Bool) -> Void) {
        isLoading = true
        let requestID = requestManager.executeRequest()
        todo.fetchTags() { [weak self] results in
            guard let self = self else {
                completion(false)
                return
            }
            
            guard self.requestManager.shouldProceed(with: requestID) else {
                completion(false)
                return
            }
            
            self.isLoading = false
            self.state = .loaded
            self.tags = results
            completion(true)
        }
    }
    
    // MARK: - TodoTagProcessorDelegate
    func didCreateTodoTag(_ tag: TodoTag) {
        loadTags {[weak self] success in
            guard success else { return }
            self?.onCreateTag?(tag)
        }
    }
}
