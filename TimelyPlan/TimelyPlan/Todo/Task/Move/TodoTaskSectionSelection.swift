//
//  TodoTaskSectionSelection.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/6.
//

import Foundation

class TodoTaskSectionSelection {
    
    var didSelectSection: ((TodoSection) -> Void)?
    
    /// 展开板块的列表标识
    private(set) var expandedSectionListID: String? = TodoSmartList.inbox.identifier
    
    private(set) var selectedSection: TodoSection = .none(for: nil)
    
    func selectSection(_ section: TodoSection) {
        selectedSection = section
        didSelectSection?(section)
    }
    
    func isSectionExpanded(for list: TodoList?) -> Bool {
        if let list = list {
            return expandedSectionListID == list.identifier
        } else {
            return expandedSectionListID == TodoSmartList.inbox.identifier
        }
    }
    
    func setSectionExpanded(_ isExpanded: Bool, for list: TodoList?) {
        let listID = list?.identifier ?? TodoSmartList.inbox.identifier
        if isExpanded {
            expandedSectionListID = listID
        } else if expandedSectionListID == listID {
            expandedSectionListID = nil
        }
    }
    
    func isSelectedList(_ list: TodoList?) -> Bool {
        guard let list = list, let selectedList = selectedSection.list else {
            return list == nil && selectedSection.list == nil
        }
        
        var isSelected = false
        var currentList: TodoList? = selectedList
        while currentList != nil {
            if currentList?.identifier == list.identifier {
                isSelected = true
                break
            }
            
            currentList = currentList?.parent
        }
        
        return isSelected
    }
    
    func isSelectedSection(_ section: TodoSection) -> Bool {
        return section.isEqual(selectedSection)
    }
}
