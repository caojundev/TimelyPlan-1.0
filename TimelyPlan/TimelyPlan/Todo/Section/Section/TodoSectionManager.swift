//
//  TodoSectionManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/3.
//

import Foundation
import CoreData

class TodoSectionManager {

    let updater = TodoSectionProcessorUpdater()
    
    // MARK: - Providers
    func getSections(for list: TodoList?) -> [TodoSection]? {
        return CDTodoSection.getSections(in: list)?.sections
    }

    // MARK: - Processors
    func createSection(with name: String, in list: TodoList?) {
        guard let content = CDTodoSection.createSection(with: name, in: list) else {
            return
        }
        
        let section = TodoSection(content: content)
        HandyRecord.save()
        updater.didCreateTodoSection(section, in: list)
    }
    
    func updateSection(_ section: TodoSection, with name: String) {
        guard CDTodoSection.updateSection(section, with: name) else {
            return
        }
        
        HandyRecord.save()
        updater.didUpdateTodoSection(section, with: name)
    }
    
    func deleteSection(_ section: TodoSection) {
        guard CDTodoSection.deleteSection(section) else {
            return
        }
        
        HandyRecord.save()
        updater.didDeleteTodoSection(section)
    }

    func reorderSection(in sections: [TodoSection], fromIndex: Int, toIndex: Int) -> Bool {
        guard CDTodoSection.reorderSection(in: sections, fromIndex: fromIndex, toIndex: toIndex) else {
            return false
        }
        
        HandyRecord.save()
        updater.didRecorderTodoSection(in: sections, fromIndex: fromIndex, toIndex: toIndex)
        return true
    }
}
