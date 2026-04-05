//
//  TodoTagSearchResultViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/5.
//

import Foundation

class TodoTagSearchResultViewModel: NSObject {

    /// 当前结果对应的搜索文本
    private(set) var searchText: String?
    
    private(set) var tags: [TodoTag]?
    
    private(set) var isLoading: Bool = false
    
    private(set) var state: TPListLoadingState = .initialLoading

    var didLoadTags: (() -> Void)?
    
    /// 搜索标签
    func searchTags(contain searchText: String?) {
        if self.searchText == searchText {
            return
        }
        
        guard let searchText = searchText, searchText.count > 0 else {
            self.searchText = nil
            self.tags = nil
            self.didLoadTags?()
            return
        }
        
        self.isLoading = true
        self.searchText = searchText
        todo.searchTags(containText: searchText) {[weak self] tags in
            guard let self = self, searchText == self.searchText else {
                return
            }

            self.isLoading = false
            self.state = .loaded
            self.tags = tags
            self.didLoadTags?()
        }
    }
}
