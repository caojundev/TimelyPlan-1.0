//
//  TodoTaskSectionViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/8.
//

import Foundation

class TodoTaskSectionViewModel {

    private(set) var inboxSections: [TodoSection]
    
    private(set) var topLists: [TodoList]?

    let selection: TodoTaskSectionSelection
    
    init(selection: TodoTaskSectionSelection) {
        self.selection = selection
        self.inboxSections = todo.getSections(for: nil) ?? []
        self.topLists = todo.getTopLists()
    }
    
    func searchItems(containText text: String, completion: @escaping ([ListDiffable]?) -> Void) {
        let lists = topLists?.flattenItems() as? [TodoList] ?? []
        DispatchQueue.global(qos: .userInitiated).async {
            var results = [ListDiffable]()
            let inboxResults = self.inboxSections.filter {
                $0.name?.localizedCaseInsensitiveContains(text) ?? false
            }
            
            results.append(contentsOf: inboxResults)
            
            /// 搜索用户列表
            for list in lists {
                if let name = list.name, name.localizedStandardContains(text) {
                    results.append(list)
                }
                
                let sections = list.sections?.filter {
                    $0.name?.localizedCaseInsensitiveContains(text) ?? false
                }
                
                if let sections = sections {
                    results.append(contentsOf: sections)
                }
            }
            
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
}
