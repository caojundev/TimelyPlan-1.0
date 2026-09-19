//
//  CountdownEventSearchViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/19.
//

import Foundation

/// 倒数日事项搜索视图模型
/// 在倒数日事项视图模型的基础上，按搜索文本过滤事项
class CountdownEventSearchViewModel: CountdownEventViewModel {
    
    /// 搜索结果分组唯一标识
    override var groupIdentifier: String {
        return "CountdownEventSearchResultGroup"
    }
    
    /// 当前搜索文本（nil 表示无搜索条件）
    private(set) var searchText: String?
    
    /// 更新搜索文本
    /// - Parameters:
    ///   - searchText: 搜索文本，空文本视为无搜索条件
    ///   - completion: 加载完成回调
    func updateSearchText(_ searchText: String?,
                          completion: (() -> Void)? = nil) {
        /// 空文本视为无搜索条件
        var text = searchText?.whitespacesAndNewlinesTrimmedString
        if text?.count == 0 {
            text = nil
        }
        
        guard self.searchText != text else {
            completion?()
            return
        }
        
        self.searchText = text
        setNeedsRefresh()
        loadEvents(completion: completion)
    }
    
    // MARK: - 加载数据
    /// 按名称搜索活动倒数日事项（谓词查询，忽略大小写）
    override func fetchEvents(completion: @escaping ([CountdownEvent]?) -> Void) {
        guard let searchText = searchText, searchText.count > 0 else {
            completion([])
            return
        }
        
        CountdownRepository.searchActiveEvents(containText: searchText,
                                               completion: completion)
    }
}
