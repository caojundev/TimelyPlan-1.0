//
//  TodoTaskSectionSelection.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/6.
//

import Foundation

class TodoTaskSectionSelection {
    
    var didSelectSection: ((TodoSectionFeature) -> Void)?
    
    /// 展开板块的列表标识
    private(set) var expandedSectionListID: String?
    
    private(set) var selectedSection: TodoSectionFeature
    
    init(section: TodoSectionFeature) {
        self.selectedSection = section
        if let list = section.list {
            expandedSectionListID = list.identifier
        } else {
            expandedSectionListID = TodoSmartList.inbox.identifier
        }
    }
    
    func selectSection(_ section: TodoSection) {
        selectedSection = section.feature
        didSelectSection?(selectedSection)
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
        
        return list.identifier == selectedList.identifier
    }
    
    func isSelectedSection(_ section: TodoSection) -> Bool {
        return selectedSection == section.feature
    }
}
