//
//  TodoSectionViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/3.
//

import Foundation

enum TodoSectionChange {
    case create(TodoSection)
    case update(TodoSection)
}

class TodoSectionViewModel: TodoSectionProcessorDelegate {
    
    /// 列表板块改变
    var onSectionsChanged: ((TodoSectionChange?) -> Void)?

    /// 占位视图
    private(set) lazy var placeholderProvider: TPDefaultPlaceholderProvider = {
        let provider = TPDefaultPlaceholderProvider()
        provider.emptyTitle = resGetString("No Sections")
        provider.emptyImage = resGetImage("todo_section_80")
        return provider
    }()
    
    /// 列表包含的板块
    private(set) var sections: [TodoSection] = []
    
    private let list: TodoList?
    
    init(list: TodoList?) {
        self.list = list
        self.updateSections()
        TodoRepository.addUpdater(self, for: [.section])
    }
    
    private func updateSections() {
        if let list = list {
            self.sections = list.sections ?? []
        } else {
            /// 收件箱
            self.sections = TodoRepository.getSections(for: nil) ?? []
        }
    }
    
    func createSection(with name: String) {
        TodoRepository.createSection(with: name, in: list)
    }
    
    func updateSection(_ section: TodoSection, with name: String) {
        TodoRepository.updateSection(section, with: name)
    }
    
    func deleteSection(_ section: TodoSection) {
        TodoRepository.deleteSection(section)
    }
    
    func reorderSection(fromIndex: Int, toIndex: Int) -> Bool {
        guard TodoRepository.reorderSection(in: sections, of: list, from: fromIndex, to: toIndex) else {
            return false
        }
        
        sections.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        return true
    }
    
    // MARK: - TodoSectionProcessorDelegate
    func didCreateTodoSection(_ section: TodoSection, in list: TodoList?) {
        updateSections()
        onSectionsChanged?(.create(section))
    }

    func didDeleteTodoSection(_ section: TodoSection) {
        updateSections()
        onSectionsChanged?(nil)
    }
    
    func didUpdateTodoSection(_ section: TodoSection) {
        updateSections()
        onSectionsChanged?(.update(section))
    }
    
}
