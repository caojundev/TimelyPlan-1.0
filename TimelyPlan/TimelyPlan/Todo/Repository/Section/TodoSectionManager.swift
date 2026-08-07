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
        guard let cdSections = CDTodoSection.getSections(in: list) else {
            return nil
        }
        
        return cdSections.sections(with: list)
    }

    // MARK: - Processors
    func createSection(with name: String, in list: TodoList?) {
        guard let content = CDTodoSection.createSection(with: name, in: list) else {
            return
        }
        
        let section = TodoSection(content: content)
        list?.addSection(section)
        
        HandyRecord.updateChangeCount()
        updater.didCreateTodoSection(section, in: list)
    }
    
    func updateSection(_ section: TodoSection, with name: String) {
        guard CDTodoSection.updateSection(section, with: name) else {
            return
        }
        
        section.name = name
        HandyRecord.updateChangeCount()
        updater.didUpdateTodoSection(section)
    }
    
    func deleteSection(_ section: TodoSection) {
        guard CDTodoSection.deleteSection(section) else {
            return
        }
        
        if let list = section.list {
            list.removeSection(section)
        }

        HandyRecord.updateChangeCount()
        updater.didDeleteTodoSection(section)
    }

    func reorderSection(in sections: [TodoSection],
                        of list: TodoList?,
                        from fromIndex: Int,
                        to toIndex: Int) -> Bool {
        guard CDTodoSection.reorderSection(in: sections,
                                           fromIndex: fromIndex,
                                           toIndex: toIndex) else {
            return false
        }
        
        list?.moveSection(at: fromIndex, to: toIndex)
        HandyRecord.updateChangeCount()
        updater.didReorderTodoSection(in: sections, of: list, from: fromIndex, to: toIndex)
        return true
    }
}
