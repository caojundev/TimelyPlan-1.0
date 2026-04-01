//
//  TodoParentListResultSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/9.
//

import Foundation

class TodoParentListSearchResultSectionController: TPTableSearchResultSectionController{
    
    var didSelectList: ((TodoList?) -> Void)?
    
    /// 当前选中列表
    var selectedList: TodoList?

    /// 允许的最大列表深度
    var allowMaxDepth: Int = .max
    
    /// 禁止选择列表
    var disabledLists: [TodoList]?
    
    /// 顶层列表数组
    var topLists: [TodoList]?

    override func fetchResults(containText text: String, completion: @escaping ([ListDiffable]?) -> Void) {
        guard let lists = topLists?.flattenItems() as? [TodoList] else {
            completion(nil)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let results = lists.filter {
                $0.name?.localizedCaseInsensitiveContains(text) ?? false
            }
            
            DispatchQueue.main.async {
                var enabledResults: [TodoList] = []
                var disabledResults: [TodoList] = []
                for result in results {
                    if self.isDisabledList(result) {
                        disabledResults.append(result)
                    } else {
                        enabledResults.append(result)
                    }
                }
                
                let orderedResults = enabledResults + disabledResults
                completion(orderedResults)
            }
        }
    }
    
    override func heightForHeader() -> CGFloat {
        return 5.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return TodoParentListSearchResultCell.self
    }

    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? TodoParentListSearchResultCell,
              let list = item(at: index) as? TodoList else {
                  return
        }
        
        cell.list = list
        cell.isDisabled = isDisabledList(list)
        highlightSearchText(for: cell)
    }
    
    override func didSelectRow(at index: Int) {
        let list = item(at: index) as! TodoList
        self.didSelectList?(list)
    }
    
    override func shouldHighlightRow(at index: Int) -> Bool {
        let list = item(at: index) as! TodoList
        return !isDisabledList(list)
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        let list = item(at: index) as! TodoList
        return self.selectedList == list
    }
    
    // MARK: -
    /// 是否为禁用列表
    func isDisabledList(_ list: TodoList) -> Bool {
        if list.depth > allowMaxDepth {
            return true
        }
        
        if let disabledLists = disabledLists {
            return disabledLists.contains(list)
        }
        
        return false
    }
}
